import Darwin
import Foundation
import IOKit

public enum ApplicationUsageMetric: Sendable {
    case cpu
    case gpu
    case memory
    case network
}

public struct ApplicationUsageEntry: Sendable {
    public let id: String
    public let name: String
    public let value: Double
    public let auxiliaryValue: Double?
}

public struct ApplicationUsageSample: Sendable {
    public let entries: [ApplicationUsageEntry]
    public let isReady: Bool
    public let totalValue: Double?

    public init(entries: [ApplicationUsageEntry], isReady: Bool, totalValue: Double? = nil) {
        self.entries = entries
        self.isReady = isReady
        self.totalValue = totalValue
    }
}

private struct ProcessIdentity {
    let id: String
    let name: String
}

private struct ProcessResourceCounters {
    let identity: ProcessIdentity
    let cpuTimeNanoseconds: UInt64
    let residentBytes: UInt64
    let gpuTimeNanoseconds: UInt64?
}

private struct TimedProcessCounter {
    let value: UInt64
}

private struct HostCPUTicks {
    let busy: UInt64
    let total: UInt64
}

private struct TimedApplicationNetworkCounter {
    let received: UInt64
    let sent: UInt64
}

private struct AGXGPUCounter {
    let accumulatedTime: UInt64
    let processName: String
}

nonisolated(unsafe) private var previousApplicationCPUCounters: [pid_t: TimedProcessCounter] = [:]
nonisolated(unsafe) private var previousApplicationCPUTimestamp: TimeInterval?
nonisolated(unsafe) private var previousApplicationCPUHostTicks: HostCPUTicks?
nonisolated(unsafe) private var previousApplicationGPUCounters: [pid_t: TimedProcessCounter] = [:]
nonisolated(unsafe) private var previousApplicationGPUTimestamp: TimeInterval?
nonisolated(unsafe) private var previousApplicationNetworkCounters: [String: TimedApplicationNetworkCounter] = [:]
nonisolated(unsafe) private var previousApplicationNetworkTimestamp: TimeInterval?
nonisolated(unsafe) private var applicationNameCache: [String: String] = [:]
private let applicationCPUCacheLock = NSLock()
private let applicationGPUCacheLock = NSLock()
private let applicationNetworkCacheLock = NSLock()
private let applicationNameCacheLock = NSLock()

public enum ApplicationUsageMonitor {
    public static func sample(_ metric: ApplicationUsageMetric) -> ApplicationUsageSample {
        switch metric {
        case .cpu:
            return cpuUsage()
        case .gpu:
            return gpuUsage()
        case .memory:
            return memoryUsage()
        case .network:
            return networkUsage()
        }
    }

    private static func cpuUsage() -> ApplicationUsageSample {
        let resources = processResources(includeGPU: false)
        let hostTicks = hostCPUTicks()
        let now = Date().timeIntervalSince1970
        let current = Dictionary(uniqueKeysWithValues: resources.map {
            ($0.pid, TimedProcessCounter(value: $0.resource.cpuTimeNanoseconds))
        })

        applicationCPUCacheLock.lock()
        let previous = previousApplicationCPUCounters
        let previousTimestamp = previousApplicationCPUTimestamp
        let previousHostTicks = previousApplicationCPUHostTicks
        previousApplicationCPUCounters = current
        previousApplicationCPUTimestamp = now
        previousApplicationCPUHostTicks = hostTicks
        applicationCPUCacheLock.unlock()

        guard let previousTimestamp else {
            return ApplicationUsageSample(entries: [], isReady: false)
        }
        let elapsed = max(0.1, now - previousTimestamp)
        var timebase = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        let nanosecondsPerTick = timebase.denom > 0
            ? Double(timebase.numer) / Double(timebase.denom)
            : 1
        let elapsedNanoseconds = elapsed * 1_000_000_000
        let logicalProcessorCount = Double(max(1, ProcessInfo.processInfo.activeProcessorCount))
        var grouped: [String: (name: String, value: Double)] = [:]

        for item in resources {
            guard let oldValue = previous[item.pid]?.value,
                  item.resource.cpuTimeNanoseconds >= oldValue else {
                continue
            }
            let delta = item.resource.cpuTimeNanoseconds - oldValue
            // Normalize process CPU time against the whole machine. A value of 1.0
            // means all available logical processors were fully occupied.
            let fraction = Double(delta) * nanosecondsPerTick
                / elapsedNanoseconds
                / logicalProcessorCount
            guard fraction > 0.0001 else {
                continue
            }
            let existing = grouped[item.resource.identity.id]
            grouped[item.resource.identity.id] = (
                item.resource.identity.name,
                (existing?.value ?? 0) + fraction
            )
        }

        let totalValue: Double?
        if let hostTicks, let previousHostTicks,
           hostTicks.busy >= previousHostTicks.busy,
           hostTicks.total >= previousHostTicks.total {
            let busyDelta = hostTicks.busy - previousHostTicks.busy
            let totalDelta = hostTicks.total - previousHostTicks.total
            totalValue = totalDelta > 0
                ? min(1, max(0, Double(busyDelta) / Double(totalDelta)))
                : nil
        } else {
            totalValue = nil
        }

        return ApplicationUsageSample(
            entries: sortedEntries(grouped.map { id, item in
                ApplicationUsageEntry(id: id, name: item.name, value: item.value, auxiliaryValue: nil)
            }),
            isReady: true,
            totalValue: totalValue
        )
    }

    private static func hostCPUTicks() -> HostCPUTicks? {
        var info = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride
        )
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else {
            return nil
        }

        let user = UInt64(info.cpu_ticks.0)
        let system = UInt64(info.cpu_ticks.1)
        let idle = UInt64(info.cpu_ticks.2)
        let nice = UInt64(info.cpu_ticks.3)
        let busy = user + system + nice
        return HostCPUTicks(busy: busy, total: busy + idle)
    }

    private static func gpuUsage() -> ApplicationUsageSample {
        let resources = gpuProcessResources()
        let now = Date().timeIntervalSince1970
        let current = Dictionary(uniqueKeysWithValues: resources.map { item in
            (item.pid, TimedProcessCounter(value: item.gpuTimeNanoseconds))
        })

        applicationGPUCacheLock.lock()
        let previous = previousApplicationGPUCounters
        let previousTimestamp = previousApplicationGPUTimestamp
        previousApplicationGPUCounters = current
        previousApplicationGPUTimestamp = now
        applicationGPUCacheLock.unlock()

        guard let previousTimestamp else {
            return ApplicationUsageSample(entries: [], isReady: false)
        }
        let elapsedNanoseconds = max(0.1, now - previousTimestamp) * 1_000_000_000
        var grouped: [String: (name: String, value: Double)] = [:]

        for item in resources {
            guard let oldValue = previous[item.pid]?.value,
                  item.gpuTimeNanoseconds >= oldValue else {
                continue
            }
            let fraction = Double(item.gpuTimeNanoseconds - oldValue) / elapsedNanoseconds
            guard fraction > 0.0001 else {
                continue
            }
            let existing = grouped[item.identity.id]
            grouped[item.identity.id] = (
                item.identity.name,
                (existing?.value ?? 0) + fraction
            )
        }

        return ApplicationUsageSample(entries: sortedEntries(grouped.map { id, item in
            ApplicationUsageEntry(id: id, name: item.name, value: item.value, auxiliaryValue: nil)
        }), isReady: true)
    }

    private static func gpuProcessResources() -> [(pid: pid_t, identity: ProcessIdentity, gpuTimeNanoseconds: UInt64)] {
        let agxTimes = agxGPUProcessTimes()
        if !agxTimes.isEmpty {
            return agxTimes.map { pid, counter in
                let resolvedIdentity = processIdentity(pid: pid)
                let identity = resolvedIdentity.name.hasPrefix("PID ")
                    ? ProcessIdentity(id: "process:\(counter.processName)", name: counter.processName)
                    : resolvedIdentity
                return (pid: pid, identity: identity, gpuTimeNanoseconds: counter.accumulatedTime)
            }
        }
        return processResources(includeGPU: true).compactMap { item in
            item.resource.gpuTimeNanoseconds.map {
                (pid: item.pid, identity: item.resource.identity, gpuTimeNanoseconds: $0)
            }
        }
    }

    private static func memoryUsage() -> ApplicationUsageSample {
        let grouped = processResources(includeGPU: false).reduce(into: [String: (name: String, bytes: UInt64)]()) { result, item in
            let existing = result[item.resource.identity.id]
            result[item.resource.identity.id] = (
                item.resource.identity.name,
                (existing?.bytes ?? 0) + item.resource.residentBytes
            )
        }

        return ApplicationUsageSample(entries: sortedEntries(grouped.map { id, item in
            ApplicationUsageEntry(id: id, name: item.name, value: Double(item.bytes), auxiliaryValue: nil)
        }), isReady: true)
    }

    private static func networkUsage() -> ApplicationUsageSample {
        guard let totals = readNetworkTotals() else {
            return ApplicationUsageSample(entries: [], isReady: true)
        }
        let now = Date().timeIntervalSince1970

        applicationNetworkCacheLock.lock()
        let previous = previousApplicationNetworkCounters
        let previousTimestamp = previousApplicationNetworkTimestamp
        previousApplicationNetworkCounters = totals
        previousApplicationNetworkTimestamp = now
        applicationNetworkCacheLock.unlock()

        guard let previousTimestamp else {
            return ApplicationUsageSample(entries: [], isReady: false)
        }
        let elapsed = max(0.1, now - previousTimestamp)
        var entries: [ApplicationUsageEntry] = []
        for (id, current) in totals {
            guard let oldValue = previous[id] else {
                continue
            }
            let received = current.received >= oldValue.received ? current.received - oldValue.received : 0
            let sent = current.sent >= oldValue.sent ? current.sent - oldValue.sent : 0
            let downRate = Double(received) / elapsed
            let upRate = Double(sent) / elapsed
            guard downRate + upRate > 1 else {
                continue
            }
            entries.append(ApplicationUsageEntry(
                id: id,
                name: displayName(forNetworkIdentity: id),
                value: downRate,
                auxiliaryValue: upRate
            ))
        }
        return ApplicationUsageSample(
            entries: entries.sorted { ($0.value + ($0.auxiliaryValue ?? 0)) > ($1.value + ($1.auxiliaryValue ?? 0)) },
            isReady: true
        )
    }

    private static func processResources(includeGPU: Bool) -> [(pid: pid_t, resource: ProcessResourceCounters)] {
        let gpuTimes: [pid_t: AGXGPUCounter] = includeGPU ? agxGPUProcessTimes() : [:]
        return processIDs().compactMap { pid -> (pid: pid_t, resource: ProcessResourceCounters)? in
            guard pid > 0, let taskInfo = taskInfo(for: pid), taskInfo.pti_resident_size > 0 else {
                return nil
            }
            let identity = processIdentity(pid: pid)
            let gpuTimeValue: UInt64?
            if includeGPU {
                gpuTimeValue = gpuTimes.isEmpty ? gpuTime(for: pid) : gpuTimes[pid]?.accumulatedTime
            } else {
                gpuTimeValue = nil
            }
            return (
                pid,
                ProcessResourceCounters(
                    identity: identity,
                    cpuTimeNanoseconds: taskInfo.pti_total_user + taskInfo.pti_total_system,
                    residentBytes: taskInfo.pti_resident_size,
                    gpuTimeNanoseconds: gpuTimeValue
                )
            )
        }
    }

    private static func agxGPUProcessTimes() -> [pid_t: AGXGPUCounter] {
        let root = IORegistryGetRootEntry(kIOMainPortDefault)
        guard root != 0 else {
            return [:]
        }
        defer { IOObjectRelease(root) }

        var iterator: io_iterator_t = 0
        guard IORegistryEntryCreateIterator(
            root,
            kIOServicePlane,
            IOOptionBits(kIORegistryIterateRecursively),
            &iterator
        ) == KERN_SUCCESS else {
            return [:]
        }
        defer { IOObjectRelease(iterator) }

        var totals: [pid_t: AGXGPUCounter] = [:]
        var service = IOIteratorNext(iterator)
        while service != 0 {
            let currentService = service
            service = IOIteratorNext(iterator)
            defer { IOObjectRelease(currentService) }

            guard IOObjectConformsTo(currentService, "AGXDeviceUserClient") != 0 else {
                continue
            }

            guard let creator = IORegistryEntryCreateCFProperty(
                currentService,
                "IOUserClientCreator" as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue() as? String,
                  let pid = creatorPID(creator),
                  let usages = IORegistryEntryCreateCFProperty(
                      currentService,
                      "AppUsage" as CFString,
                      kCFAllocatorDefault,
                      0
                  )?.takeRetainedValue() as? [[String: Any]] else {
                continue
            }

            let accumulatedTime = usages.reduce(UInt64(0)) { result, usage in
                guard let value = usage["accumulatedGPUTime"] as? NSNumber else {
                    return result
                }
                return result + value.uint64Value
            }
            let processName = creatorProcessName(creator)
            let previous = totals[pid]?.accumulatedTime ?? 0
            totals[pid] = AGXGPUCounter(
                accumulatedTime: previous + accumulatedTime,
                processName: processName
            )
        }
        return totals
    }

    private static func creatorPID(_ creator: String) -> pid_t? {
        guard creator.hasPrefix("pid "),
              let comma = creator.firstIndex(of: ",") else {
            return nil
        }
        let start = creator.index(creator.startIndex, offsetBy: 4)
        return pid_t(creator[start..<comma])
    }

    private static func creatorProcessName(_ creator: String) -> String {
        guard let comma = creator.firstIndex(of: ",") else {
            return creator
        }
        return creator[creator.index(after: comma)...].trimmingCharacters(in: .whitespaces)
    }

    private static func processIDs() -> [pid_t] {
        let requiredBytes = proc_listpids(UInt32(PROC_ALL_PIDS), 0, nil, 0)
        guard requiredBytes > 0 else {
            return []
        }
        var pids = [pid_t](repeating: 0, count: Int(requiredBytes) / MemoryLayout<pid_t>.stride + 32)
        let copiedBytes = pids.withUnsafeMutableBytes { buffer in
            proc_listpids(UInt32(PROC_ALL_PIDS), 0, buffer.baseAddress, Int32(buffer.count))
        }
        guard copiedBytes > 0 else {
            return []
        }
        return Array(pids.prefix(Int(copiedBytes) / MemoryLayout<pid_t>.stride)).filter { $0 > 0 }
    }

    private static func taskInfo(for pid: pid_t) -> proc_taskinfo? {
        var info = proc_taskinfo()
        let expectedSize = MemoryLayout<proc_taskinfo>.stride
        let copied = withUnsafeMutablePointer(to: &info) { pointer in
            proc_pidinfo(pid, PROC_PIDTASKINFO, 0, pointer, Int32(expectedSize))
        }
        return copied == expectedSize ? info : nil
    }

    private static func gpuTime(for pid: pid_t) -> UInt64? {
        var task = mach_port_name_t()
        guard task_name_for_pid(mach_task_self_, pid, &task) == KERN_SUCCESS, task != MACH_PORT_NULL else {
            return nil
        }
        defer { mach_port_deallocate(mach_task_self_, task) }

        var info = task_power_info_v2_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<task_power_info_v2_data_t>.stride / MemoryLayout<natural_t>.stride
        )
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(task, task_flavor_t(TASK_POWER_INFO_V2), rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else {
            return nil
        }
        return info.gpu_energy.task_gpu_utilisation
    }

    private static func processIdentity(pid: pid_t) -> ProcessIdentity {
        var pathBuffer = [CChar](repeating: 0, count: Int(MAXPATHLEN) * 4)
        let pathLength = proc_pidpath(pid, &pathBuffer, UInt32(pathBuffer.count))
        if pathLength > 0 {
            let path = decodedCString(pathBuffer)
            if let appPath = outermostApplicationPath(in: path) {
                return ProcessIdentity(id: appPath, name: applicationDisplayName(path: appPath))
            }
        }

        var nameBuffer = [CChar](repeating: 0, count: 256)
        let nameLength = proc_name(pid, &nameBuffer, UInt32(nameBuffer.count))
        let name = nameLength > 0 ? decodedCString(nameBuffer) : "PID \(pid)"
        return ProcessIdentity(id: "process:\(name)", name: name)
    }

    private static func outermostApplicationPath(in executablePath: String) -> String? {
        let components = URL(fileURLWithPath: executablePath).pathComponents
        guard let appIndex = components.firstIndex(where: { $0.hasSuffix(".app") }) else {
            return nil
        }
        return NSString.path(withComponents: Array(components.prefix(through: appIndex)))
    }

    private static func decodedCString(_ buffer: [CChar]) -> String {
        let bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
        return String(decoding: bytes, as: UTF8.self)
    }

    private static func applicationDisplayName(path: String) -> String {
        applicationNameCacheLock.lock()
        if let cached = applicationNameCache[path] {
            applicationNameCacheLock.unlock()
            return cached
        }
        applicationNameCacheLock.unlock()

        let fallback = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
        let bundle = Bundle(path: path)
        let name = bundle?.localizedInfoDictionary?["CFBundleDisplayName"] as? String
            ?? bundle?.localizedInfoDictionary?["CFBundleName"] as? String
            ?? bundle?.infoDictionary?["CFBundleDisplayName"] as? String
            ?? bundle?.infoDictionary?["CFBundleName"] as? String
            ?? fallback

        applicationNameCacheLock.lock()
        applicationNameCache[path] = name
        applicationNameCacheLock.unlock()
        return name
    }

    private static func readNetworkTotals() -> [String: TimedApplicationNetworkCounter]? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/nettop")
        process.arguments = ["-P", "-L", "1", "-x", "-J", "bytes_in,bytes_out"]
        let output = Pipe()
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
        } catch {
            return nil
        }
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0,
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }

        var totals: [String: TimedApplicationNetworkCounter] = [:]
        for line in text.split(whereSeparator: \Character.isNewline).dropFirst() {
            let columns = line.split(separator: ",", omittingEmptySubsequences: false)
            guard columns.count >= 3,
                  let received = UInt64(columns[1]),
                  let sent = UInt64(columns[2]) else {
                continue
            }
            let processColumn = String(columns[0])
            guard let separator = processColumn.lastIndex(of: "."),
                  let pid = pid_t(processColumn[processColumn.index(after: separator)...]) else {
                continue
            }
            let identity = processIdentity(pid: pid)
            let existing = totals[identity.id]
            totals[identity.id] = TimedApplicationNetworkCounter(
                received: (existing?.received ?? 0) + received,
                sent: (existing?.sent ?? 0) + sent
            )
        }
        return totals
    }

    private static func displayName(forNetworkIdentity id: String) -> String {
        if id.hasPrefix("process:") {
            return String(id.dropFirst("process:".count))
        }
        return applicationDisplayName(path: id)
    }

    private static func sortedEntries(_ entries: [ApplicationUsageEntry]) -> [ApplicationUsageEntry] {
        entries.sorted { $0.value > $1.value }
    }
}
