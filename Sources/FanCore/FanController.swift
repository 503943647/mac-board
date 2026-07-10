import Foundation

public struct Fan: Sendable {
    public let index: Int
    public let actualRPM: Double?
    public let minRPM: Double?
    public let maxRPM: Double?
    public let targetRPM: Double?
    public let forced: Bool
}

public struct TemperatureReading: Sendable {
    public let key: String
    public let name: String
    public let celsius: Double
}

public final class FanController {
    private let smc: SMC

    public init(smc: SMC) {
        self.smc = smc
    }

    public func fans() throws -> [Fan] {
        let count = fanCount()
        let mask = forcedFanMask()
        return (0..<count).map { index in
            Fan(
                index: index,
                actualRPM: try? readRPM("F\(index)Ac"),
                minRPM: try? readRPM("F\(index)Mn"),
                maxRPM: try? readRPM("F\(index)Mx"),
                targetRPM: try? readRPM("F\(index)Tg"),
                forced: (mask & (1 << index)) != 0
            )
        }
    }

    public func temperatures() throws -> [TemperatureReading] {
        var readings: [TemperatureReading] = []

        for key in try temperatureKeys() {
            guard let value = try? smc.read(key), value.bytes.count >= 2 else {
                continue
            }

            let celsius: Double
            switch value.dataType {
            case "sp78":
                celsius = decodeSP78(value.bytes)
            case "flt ":
                celsius = decodeFloat(value.bytes)
            default:
                continue
            }

            if celsius > 1, celsius < 130 {
                readings.append(TemperatureReading(key: key, name: SensorNames.name(for: key), celsius: celsius))
            }
        }

        return readings.sorted { lhs, rhs in
            if lhs.name == rhs.name {
                return lhs.key < rhs.key
            }
            return lhs.name < rhs.name
        }
    }

    public func setSystemMode() throws {
        if hasKey("FS! ") {
            try setForcedFanMask(0)
            return
        }

        for fan in try fans() {
            try smc.write("F\(fan.index)Md", dataType: "ui8 ", bytes: [0])
        }
    }

    public func setMaxMode() throws {
        let fanList = try fans()
        guard !fanList.isEmpty else {
            throw ControlError.noFans
        }

        for fan in fanList {
            guard let max = fan.maxRPM else {
                continue
            }
            try setFanForced(fan.index, enabled: true)
            try writeRPM("F\(fan.index)Tg", rpm: max)
        }
    }

    public func setManual(fanIndex: Int, rpm: Double) throws {
        let fanList = try fans()
        guard let fan = fanList.first(where: { $0.index == fanIndex }) else {
            throw ControlError.fanNotFound(fanIndex)
        }

        let min = fan.minRPM ?? 0
        let max = fan.maxRPM ?? 10_000
        guard rpm >= min, rpm <= max else {
            throw ControlError.rpmOutOfRange(rpm: rpm, min: min, max: max)
        }

        try setFanForced(fanIndex, enabled: true)
        try writeRPM("F\(fanIndex)Tg", rpm: rpm)
    }

    public func setManualAll(rpm: Double) throws {
        let fanList = try fans()
        guard !fanList.isEmpty else {
            throw ControlError.noFans
        }

        let min = fanList.compactMap(\.minRPM).max() ?? 0
        let max = fanList.compactMap(\.maxRPM).min() ?? 10_000
        guard rpm >= min, rpm <= max else {
            throw ControlError.rpmOutOfRange(rpm: rpm, min: min, max: max)
        }

        for fan in fanList {
            try setFanForced(fan.index, enabled: true)
            try writeRPM("F\(fan.index)Tg", rpm: rpm)
        }
    }

    public func listSMCKeys(prefix: String?) throws -> [String] {
        let count = try smc.keyCount()
        var keys: [String] = []
        for index in 0..<count {
            let key = try smc.key(at: index)
            if let prefix, !key.hasPrefix(prefix) {
                continue
            }
            keys.append(key)
        }
        return keys
    }

    private func fanCount() -> Int {
        guard let value = try? smc.read("FNum"), let first = value.bytes.first else {
            return 0
        }
        return Int(first)
    }

    private func readRPM(_ key: String) throws -> Double {
        let value = try smc.read(key)
        guard value.bytes.count >= 2 else {
            throw SMCError.invalidData("\(key) did not return an RPM value.")
        }

        switch value.dataType {
        case "fpe2":
            return decodeFPE2(value.bytes)
        case "flt ":
            return decodeFloat(value.bytes)
        case "ui16":
            return Double(decodeUInt16(value.bytes))
        default:
            throw SMCError.invalidData("\(key) uses unsupported type \(value.dataType).")
        }
    }

    private func writeRPM(_ key: String, rpm: Double) throws {
        let existing = try smc.read(key)
        switch existing.dataType {
        case "flt ":
            try smc.write(key, dataType: "flt ", bytes: encodeFloat(rpm))
        case "fpe2":
            try smc.write(key, dataType: "fpe2", bytes: encodeFPE2(rpm))
        case "ui16":
            try smc.write(key, dataType: "ui16", bytes: encodeUInt16(UInt16(rpm.rounded())))
        default:
            throw SMCError.invalidData("\(key) uses unsupported writable type \(existing.dataType).")
        }
    }

    private func forcedFanMask() -> UInt16 {
        if let value = try? smc.read("FS! "), value.bytes.count >= 2 {
            return decodeUInt16(value.bytes)
        }

        let count = fanCount()
        var mask: UInt16 = 0
        for index in 0..<count {
            guard let value = try? smc.read("F\(index)Md"), let mode = value.bytes.first else {
                continue
            }
            if mode != 0 {
                mask |= UInt16(1 << index)
            }
        }
        return mask
    }

    private func setFanForced(_ index: Int, enabled: Bool) throws {
        if hasKey("FS! ") {
            let bit = UInt16(1 << index)
            let mask = enabled ? (forcedFanMask() | bit) : (forcedFanMask() & ~bit)
            try setForcedFanMask(mask)
            return
        }

        try smc.write("F\(index)Md", dataType: "ui8 ", bytes: [enabled ? 1 : 0])
    }

    private func hasKey(_ key: String) -> Bool {
        (try? smc.read(key)) != nil
    }

    private func setForcedFanMask(_ mask: UInt16) throws {
        guard hasKey("FS! ") else {
            return
        }
        try smc.write("FS! ", dataType: "ui16", bytes: encodeUInt16(mask))
    }

    private func temperatureKeys() throws -> [String] {
        do {
            let allKeys = try listSMCKeys(prefix: "T")
            let candidates = allKeys.filter { key in
                guard let value = try? smc.read(key) else {
                    return false
                }
                return value.dataType == "sp78" || value.dataType == "flt "
            }
            if !candidates.isEmpty {
                return candidates
            }
        } catch {
            // Some Macs deny key enumeration. Fall back to common SMC temperature keys.
        }

        return SensorNames.commonTemperatureKeys
    }
}

public enum ControlError: Error, CustomStringConvertible {
    case noFans
    case fanNotFound(Int)
    case rpmOutOfRange(rpm: Double, min: Double, max: Double)

    public var description: String {
        switch self {
        case .noFans:
            return "No fans were detected on this Mac."
        case .fanNotFound(let index):
            return "Fan \(index) was not found."
        case .rpmOutOfRange(let rpm, let min, let max):
            return "Requested \(Int(rpm)) RPM is outside the hardware range \(Int(min))-\(Int(max)) RPM."
        }
    }
}

private func decodeFloat(_ bytes: [UInt8]) -> Double {
    guard bytes.count >= 4 else {
        return .nan
    }
    let raw = UInt32(bytes[0]) | UInt32(bytes[1]) << 8 | UInt32(bytes[2]) << 16 | UInt32(bytes[3]) << 24
    return Double(Float(bitPattern: raw))
}

private func encodeFloat(_ value: Double) -> [UInt8] {
    let raw = Float(value).bitPattern
    return [
        UInt8(raw & 0xff),
        UInt8((raw >> 8) & 0xff),
        UInt8((raw >> 16) & 0xff),
        UInt8((raw >> 24) & 0xff)
    ]
}
