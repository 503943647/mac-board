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

nonisolated(unsafe) private var previousCPUTicks: CPUTicks?
nonisolated(unsafe) private var previousNetworkCounters: NetworkCounters?
private let cpuLock = NSLock()
private let networkLock = NSLock()

public struct SystemSnapshot: Sendable {
    public let cpuLoad: Double?
    public let gpuLoad: Double?
    public let memoryUsed: UInt64?
    public let memoryTotal: UInt64?
    public let diskUsed: UInt64?
    public let diskTotal: UInt64?
    public let batteryPercent: Int?
    public let isCharging: Bool?
    public let networkDownBytesPerSecond: Double?
    public let networkUpBytesPerSecond: Double?

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
    public static func snapshot() -> SystemSnapshot {
        let memory = memoryUsage()
        let disk = diskUsage()
        let battery = batteryStatus()
        let network = networkUsage()

        return SystemSnapshot(
            cpuLoad: cpuUsage(),
            gpuLoad: gpuUsage(),
            memoryUsed: memory?.used,
            memoryTotal: memory?.total,
            diskUsed: disk?.used,
            diskTotal: disk?.total,
            batteryPercent: battery.percent,
            isCharging: battery.isCharging,
            networkDownBytesPerSecond: network?.down,
            networkUpBytesPerSecond: network?.up
        )
    }

    private static func cpuUsage() -> Double? {
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
        var current = CPUTicks(user: 0, nice: 0, system: 0, idle: 0)
        for cpu in 0..<Int(processorCount) {
            let base = cpu * stride
            current.user += UInt64(cpuInfo[base + Int(CPU_STATE_USER)])
            current.nice += UInt64(cpuInfo[base + Int(CPU_STATE_NICE)])
            current.system += UInt64(cpuInfo[base + Int(CPU_STATE_SYSTEM)])
            current.idle += UInt64(cpuInfo[base + Int(CPU_STATE_IDLE)])
        }

        cpuLock.lock()
        defer { cpuLock.unlock() }

        guard let previous = previousCPUTicks else {
            previousCPUTicks = current
            return 0
        }
        previousCPUTicks = current

        let busy = current.busy >= previous.busy ? current.busy - previous.busy : 0
        let total = current.total >= previous.total ? current.total - previous.total : 0
        guard total > 0 else {
            return nil
        }
        return min(1, max(0, Double(busy) / Double(total)))
    }

    private static func gpuUsage() -> Double? {
        let matching = IOServiceMatching("IOAccelerator")
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return nil
        }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer { service = IOIteratorNext(iterator) }

            if let value = gpuUsage(from: service) {
                IOObjectRelease(service)
                return value
            }
            IOObjectRelease(service)
        }

        return nil
    }

    private static func gpuUsage(from service: io_object_t) -> Double? {
        guard let property = IORegistryEntryCreateCFProperty(
            service,
            "PerformanceStatistics" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? [String: Any] else {
            return nil
        }

        let keys = ["Device Utilization %", "Renderer Utilization %", "Tiler Utilization %"]
        for key in keys {
            if let value = property[key] as? Double {
                return min(1, max(0, value / 100))
            }
            if let value = property[key] as? Int {
                return min(1, max(0, Double(value) / 100))
            }
            if let value = property[key] as? NSNumber {
                return min(1, max(0, value.doubleValue / 100))
            }
        }
        return nil
    }

    private static func memoryUsage() -> (used: UInt64, total: UInt64)? {
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
        return (total > reclaimable ? total - reclaimable : 0, total)
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

    private static func networkUsage() -> (down: Double, up: Double)? {
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
            return (0, 0)
        }
        previousNetworkCounters = current

        let elapsed = max(0.1, current.timestamp - previous.timestamp)
        let downBytes = current.received >= previous.received ? current.received - previous.received : 0
        let upBytes = current.sent >= previous.sent ? current.sent - previous.sent : 0
        return (Double(downBytes) / elapsed, Double(upBytes) / elapsed)
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
