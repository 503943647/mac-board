import Darwin
import Foundation
import IOKit
import IOKit.ps
import MachO

private struct CPUTicks {
    var user: UInt64
    var nice: UInt64
    var system: UInt64
    var idle: UInt64

    var busy: UInt64 {
        user + nice + system
    }

    var total: UInt64 {
        busy + idle
    }
}

private struct NetworkCounters {
    let received: UInt64
    let sent: UInt64
    let timestamp: TimeInterval
}

private struct HardwareIdentity: Sendable {
    let processorModel: String?
    let cpuCoreCount: Int?
    let gpuCoreCount: Int?
}

private struct CPUUsageSnapshot {
    let total: Double
    let cores: [Double]
}

private struct GPUUsageSnapshot {
    let device: Double?
    let renderer: Double?
    let tiler: Double?

    var preferred: Double? {
        device ?? renderer ?? tiler
    }
}

nonisolated(unsafe) private var previousPerCoreCPUTicks: [CPUTicks]?
nonisolated(unsafe) private var previousNetworkCounters: NetworkCounters?
private let cpuLock = NSLock()
private let networkLock = NSLock()

public struct SystemSnapshot: Sendable {
    public let processorModel: String?
    public let cpuCoreCount: Int?
    public let gpuCoreCount: Int?
    public let cpuLoad: Double?
    public let cpuCoreLoads: [Double]?
    public let gpuLoad: Double?
    public let gpuDeviceLoad: Double?
    public let gpuRendererLoad: Double?
    public let gpuTilerLoad: Double?
    public let memoryUsed: UInt64?
    public let memoryTotal: UInt64?
    public let memoryActive: UInt64?
    public let memoryWired: UInt64?
    public let memoryCompressed: UInt64?
    public let memoryInactive: UInt64?
    public let diskUsed: UInt64?
    public let diskTotal: UInt64?
    public let batteryPercent: Int?
    public let isCharging: Bool?
    public let networkDownBytesPerSecond: Double?
    public let networkUpBytesPerSecond: Double?
    public let networkReceivedBytes: UInt64?
    public let networkSentBytes: UInt64?

    public var memoryPercent: Double? {
        guard let memoryUsed, let memoryTotal, memoryTotal > 0 else {
            return nil
        }
        return Double(memoryUsed) / Double(memoryTotal)
    }

    public var diskPercent: Double? {
        guard let diskUsed, let diskTotal, diskTotal > 0 else {
            return nil
        }
        return Double(diskUsed) / Double(diskTotal)
    }
}

public enum SystemMonitor {
    private static let hardwareIdentity = HardwareIdentity(
        processorModel: sysctlString("machdep.cpu.brand_string"),
        cpuCoreCount: sysctlInteger("hw.physicalcpu"),
        gpuCoreCount: readGPUCoreCount()
    )

    public static func snapshot() -> SystemSnapshot {
        let cpu = cpuUsage()
        let gpu = gpuUsage()
        let memory = memoryUsage()
        let disk = diskUsage()
        let battery = batteryStatus()
        let network = networkUsage()

        return SystemSnapshot(
            processorModel: hardwareIdentity.processorModel,
            cpuCoreCount: hardwareIdentity.cpuCoreCount,
            gpuCoreCount: hardwareIdentity.gpuCoreCount,
            cpuLoad: cpu?.total,
            cpuCoreLoads: cpu?.cores,
            gpuLoad: gpu?.preferred,
            gpuDeviceLoad: gpu?.device,
            gpuRendererLoad: gpu?.renderer,
            gpuTilerLoad: gpu?.tiler,
            memoryUsed: memory?.used,
            memoryTotal: memory?.total,
            memoryActive: memory?.active,
            memoryWired: memory?.wired,
            memoryCompressed: memory?.compressed,
            memoryInactive: memory?.inactive,
            diskUsed: disk?.used,
            diskTotal: disk?.total,
            batteryPercent: battery.percent,
            isCharging: battery.isCharging,
            networkDownBytesPerSecond: network?.down,
            networkUpBytesPerSecond: network?.up,
            networkReceivedBytes: network?.received,
            networkSentBytes: network?.sent
        )
    }

    private static func sysctlString(_ name: String) -> String? {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 1 else {
            return nil
        }

        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else {
            return nil
        }

        let bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
        let value = String(decoding: bytes, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    private static func sysctlInteger(_ name: String) -> Int? {
        var value: Int32 = 0
        var size = MemoryLayout.size(ofValue: value)
        guard sysctlbyname(name, &value, &size, nil, 0) == 0, value > 0 else {
            return nil
        }
        return Int(value)
    }

    private static func readGPUCoreCount() -> Int? {
        let matching = IOServiceMatching("AGXAccelerator")
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return nil
        }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            let currentService = service
            service = IOIteratorNext(iterator)

            let property = IORegistryEntryCreateCFProperty(
                currentService,
                "gpu-core-count" as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue()
            IOObjectRelease(currentService)

            if let count = property as? NSNumber, count.intValue > 0 {
                return count.intValue
            }
        }

        return nil
    }

    private static func cpuUsage() -> CPUUsageSnapshot? {
        var cpuInfo: processor_info_array_t?
        var processorCount: mach_msg_type_number_t = 0
        var infoCount: mach_msg_type_number_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &processorCount,
            &cpuInfo,
            &infoCount
        )
        guard result == KERN_SUCCESS, let cpuInfo else {
            return nil
        }
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: cpuInfo),
                vm_size_t(Int(infoCount) * MemoryLayout<integer_t>.stride)
            )
        }

        let stride = Int(CPU_STATE_MAX)
        var currentCores: [CPUTicks] = []
        currentCores.reserveCapacity(Int(processorCount))
        for cpu in 0..<Int(processorCount) {
            let base = cpu * stride
            currentCores.append(CPUTicks(
                user: UInt64(cpuInfo[base + Int(CPU_STATE_USER)]),
                nice: UInt64(cpuInfo[base + Int(CPU_STATE_NICE)]),
                system: UInt64(cpuInfo[base + Int(CPU_STATE_SYSTEM)]),
                idle: UInt64(cpuInfo[base + Int(CPU_STATE_IDLE)])
            ))
        }

        cpuLock.lock()
        defer { cpuLock.unlock() }

        guard let previousCores = previousPerCoreCPUTicks,
              previousCores.count == currentCores.count else {
            previousPerCoreCPUTicks = currentCores
            return CPUUsageSnapshot(total: 0, cores: Array(repeating: 0, count: currentCores.count))
        }
        previousPerCoreCPUTicks = currentCores

        var totalBusy: UInt64 = 0
        var totalTicks: UInt64 = 0
        let coreLoads = zip(currentCores, previousCores).map { current, previous -> Double in
            let busy = current.busy >= previous.busy ? current.busy - previous.busy : 0
            let total = current.total >= previous.total ? current.total - previous.total : 0
            totalBusy += busy
            totalTicks += total
            guard total > 0 else {
                return 0
            }
            return min(1, max(0, Double(busy) / Double(total)))
        }
        guard totalTicks > 0 else {
            return nil
        }
        return CPUUsageSnapshot(
            total: min(1, max(0, Double(totalBusy) / Double(totalTicks))),
            cores: coreLoads
        )
    }

    private static func gpuUsage() -> GPUUsageSnapshot? {
        let matching = IOServiceMatching("IOAccelerator")
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return nil
        }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            let currentService = service
            service = IOIteratorNext(iterator)

            if let value = gpuUsage(from: currentService) {
                IOObjectRelease(currentService)
                return value
            }
            IOObjectRelease(currentService)
        }

        return nil
    }

    private static func gpuUsage(from service: io_object_t) -> GPUUsageSnapshot? {
        guard let property = IORegistryEntryCreateCFProperty(
            service,
            "PerformanceStatistics" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? [String: Any] else {
            return nil
        }

        let snapshot = GPUUsageSnapshot(
            device: utilization(property["Device Utilization %"]),
            renderer: utilization(property["Renderer Utilization %"]),
            tiler: utilization(property["Tiler Utilization %"])
        )
        return snapshot.preferred == nil ? nil : snapshot
    }

    private static func utilization(_ rawValue: Any?) -> Double? {
        let value: Double?
        switch rawValue {
        case let number as NSNumber:
            value = number.doubleValue
        case let number as Double:
            value = number
        case let number as Int:
            value = Double(number)
        default:
            value = nil
        }
        return value.map { min(1, max(0, $0 / 100)) }
    }

    private static func memoryUsage() -> (
        used: UInt64,
        total: UInt64,
        active: UInt64,
        wired: UInt64,
        compressed: UInt64,
        inactive: UInt64
    )? {
        let total = UInt64(ProcessInfo.processInfo.physicalMemory)
        guard total > 0 else {
            return nil
        }

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
        let result = withUnsafeMutablePointer(to: &stats) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, rebound, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return nil
        }

        var pageSizeValue = vm_size_t()
        host_page_size(mach_host_self(), &pageSizeValue)
        let pageSize = UInt64(pageSizeValue)
        let free = UInt64(stats.free_count + stats.speculative_count) * pageSize
        let inactive = UInt64(stats.inactive_count) * pageSize
        let purgeable = UInt64(stats.purgeable_count) * pageSize
        let reclaimable = min(total, free + inactive + purgeable)
        return (
            used: total > reclaimable ? total - reclaimable : 0,
            total: total,
            active: UInt64(stats.active_count) * pageSize,
            wired: UInt64(stats.wire_count) * pageSize,
            compressed: UInt64(stats.compressor_page_count) * pageSize,
            inactive: inactive
        )
    }

    private static func diskUsage() -> (used: UInt64, total: UInt64)? {
        let url = URL(fileURLWithPath: "/")
        let keys: Set<URLResourceKey> = [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeAvailableCapacityKey
        ]

        guard let values = try? url.resourceValues(forKeys: keys) else {
            return nil
        }

        let total = UInt64(values.volumeTotalCapacity ?? 0)
        guard total > 0 else {
            return nil
        }
        let available = UInt64(values.volumeAvailableCapacityForImportantUsage ?? Int64(values.volumeAvailableCapacity ?? 0))
        return (total > available ? total - available : 0, total)
    }

    private static func batteryStatus() -> (percent: Int?, isCharging: Bool?) {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let source = sources.first,
              let description = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any]
        else {
            return (nil, nil)
        }

        let current = description[kIOPSCurrentCapacityKey] as? Int
        let max = description[kIOPSMaxCapacityKey] as? Int
        let state = description[kIOPSPowerSourceStateKey] as? String
        let percent = current.flatMap { current in
            max.flatMap { max in
                max > 0 ? Int((Double(current) / Double(max) * 100).rounded()) : nil
            }
        }

        return (percent, state == kIOPSACPowerValue)
    }

    private static func networkUsage() -> (down: Double, up: Double, received: UInt64, sent: UInt64)? {
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0, let first = interfaces else {
            return nil
        }
        defer { freeifaddrs(interfaces) }

        var received: UInt64 = 0
        var sent: UInt64 = 0
        var foundInterface = false
        var pointer: UnsafeMutablePointer<ifaddrs>? = first
        while let current = pointer {
            defer { pointer = current.pointee.ifa_next }

            let flags = Int32(current.pointee.ifa_flags)
            guard (flags & IFF_UP) != 0, (flags & IFF_LOOPBACK) == 0 else {
                continue
            }
            guard let address = current.pointee.ifa_addr, Int32(address.pointee.sa_family) == AF_LINK else {
                continue
            }
            guard let data = current.pointee.ifa_data else {
                continue
            }

            foundInterface = true
            let interfaceData = data.assumingMemoryBound(to: if_data.self).pointee
            received += UInt64(interfaceData.ifi_ibytes)
            sent += UInt64(interfaceData.ifi_obytes)
        }

        guard foundInterface else {
            return nil
        }

        let now = Date().timeIntervalSince1970
        let current = NetworkCounters(received: received, sent: sent, timestamp: now)

        networkLock.lock()
        defer { networkLock.unlock() }

        guard let previous = previousNetworkCounters else {
            previousNetworkCounters = current
            return (0, 0, received, sent)
        }
        previousNetworkCounters = current

        let elapsed = max(0.1, current.timestamp - previous.timestamp)
        let downBytes = current.received >= previous.received ? current.received - previous.received : 0
        let upBytes = current.sent >= previous.sent ? current.sent - previous.sent : 0
        return (Double(downBytes) / elapsed, Double(upBytes) / elapsed, received, sent)
    }
}

public func formatBytes(_ bytes: UInt64) -> String {
    let units = ["B", "KB", "MB", "GB", "TB"]
    var value = Double(bytes)
    var unit = 0
    while value >= 1024, unit < units.count - 1 {
        value /= 1024
        unit += 1
    }
    return unit <= 1 ? "\(Int(value)) \(units[unit])" : String(format: "%.1f %@", value, units[unit])
}

public func formatRate(_ bytesPerSecond: Double) -> String {
    "\(formatBytes(UInt64(max(0, bytesPerSecond))))/s"
}
