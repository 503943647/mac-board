import Foundation
import IOKit

private let kSMCHandleYPCEvent: UInt32 = 2

private let kSMCReadKey: UInt8 = 5
private let kSMCWriteKey: UInt8 = 6
private let kSMCGetKeyFromIndex: UInt8 = 8
private let kSMCGetKeyInfo: UInt8 = 9

private struct SMCVersion {
    var major: UInt8 = 0
    var minor: UInt8 = 0
    var build: UInt8 = 0
    var reserved: UInt8 = 0
    var release: UInt16 = 0
}

private struct SMCPowerLimitData {
    var version: UInt16 = 0
    var length: UInt16 = 0
    var cpuPLimit: UInt32 = 0
    var gpuPLimit: UInt32 = 0
    var memPLimit: UInt32 = 0
}

public struct SMCKeyInfo {
    var dataSize: UInt32 = 0
    var dataType: UInt32 = 0
    var dataAttributes: UInt8 = 0
    private var padding: (UInt8, UInt8, UInt8) = (0, 0, 0)
}

private struct SMCKeyData {
    var key: UInt32 = 0
    var vers = SMCVersion()
    var pLimitData = SMCPowerLimitData()
    var keyInfo = SMCKeyInfo()
    var result: UInt8 = 0
    var status: UInt8 = 0
    var data8: UInt8 = 0
    var data32: UInt32 = 0
    var bytes: (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    ) = (
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    )
}

public struct SMCValue {
    public let key: String
    public let dataType: String
    public let bytes: [UInt8]
}

public enum SMCError: Error, CustomStringConvertible {
    case serviceNotFound
    case openFailed(kern_return_t)
    case callFailed(String, kern_return_t)
    case keyNotFound(String)
    case invalidKey(String)
    case invalidData(String)

    public var description: String {
        switch self {
        case .serviceNotFound:
            return "AppleSMC service was not found on this Mac."
        case .openFailed(let code):
            return "Failed to open AppleSMC connection: \(machError(code))."
        case .callFailed(let operation, let code):
            return "\(operation) failed: \(machError(code))."
        case .keyNotFound(let key):
            return "SMC key \(key) was not found."
        case .invalidKey(let key):
            return "Invalid SMC key \(key). Keys must be exactly 4 ASCII characters."
        case .invalidData(let message):
            return message
        }
    }
}

public final class SMC {
    private var connection: io_connect_t = 0

    public init() throws {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else {
            throw SMCError.serviceNotFound
        }
        defer { IOObjectRelease(service) }

        let result = IOServiceOpen(service, mach_task_self_, 0, &connection)
        guard result == kIOReturnSuccess else {
            throw SMCError.openFailed(result)
        }

    }

    deinit {
        if connection != 0 {
            IOServiceClose(connection)
        }
    }

    public func read(_ key: String) throws -> SMCValue {
        let info = try keyInfo(key)
        var input = SMCKeyData()
        var output = SMCKeyData()
        input.key = try fourCC(key)
        input.keyInfo.dataSize = info.dataSize
        input.data8 = kSMCReadKey

        try call(input: &input, output: &output, operation: "Read \(key)")

        let bytes = tupleToArray(output.bytes, count: Int(info.dataSize))
        return SMCValue(key: key, dataType: fourCCString(info.dataType), bytes: bytes)
    }

    public func write(_ key: String, dataType: String, bytes: [UInt8]) throws {
        guard bytes.count <= 32 else {
            throw SMCError.invalidData("SMC values cannot exceed 32 bytes.")
        }

        var input = SMCKeyData()
        var output = SMCKeyData()
        input.key = try fourCC(key)
        input.keyInfo.dataSize = UInt32(bytes.count)
        input.keyInfo.dataType = try fourCC(dataType)
        input.bytes = arrayToTuple(bytes)
        input.data8 = kSMCWriteKey

        try call(input: &input, output: &output, operation: "Write \(key)")
    }

    public func keyCount() throws -> Int {
        let value = try read("#KEY")
        guard value.bytes.count >= 4 else {
            throw SMCError.invalidData("#KEY did not return a 32-bit count.")
        }
        return Int(decodeUInt32(value.bytes))
    }

    public func key(at index: Int) throws -> String {
        var input = SMCKeyData()
        var output = SMCKeyData()
        input.data8 = kSMCGetKeyFromIndex
        input.data32 = UInt32(index)

        try call(input: &input, output: &output, operation: "Read SMC key at index \(index)")
        return fourCCString(output.key)
    }

    private func keyInfo(_ key: String) throws -> SMCKeyInfo {
        var input = SMCKeyData()
        var output = SMCKeyData()
        input.key = try fourCC(key)
        input.data8 = kSMCGetKeyInfo

        try call(input: &input, output: &output, operation: "Read info for \(key)")
        guard output.result == 0 else {
            throw SMCError.keyNotFound(key)
        }
        return output.keyInfo
    }

    private func call(input: inout SMCKeyData, output: inout SMCKeyData, operation: String) throws {
        let inputSize = MemoryLayout<SMCKeyData>.stride
        var outputSize = MemoryLayout<SMCKeyData>.stride

        let result = withUnsafePointer(to: &input) { inputPointer in
            inputPointer.withMemoryRebound(to: UInt8.self, capacity: inputSize) { inputBytes in
                withUnsafeMutablePointer(to: &output) { outputPointer in
                    outputPointer.withMemoryRebound(to: UInt8.self, capacity: outputSize) { outputBytes in
                        IOConnectCallStructMethod(
                            connection,
                            kSMCHandleYPCEvent,
                            inputBytes,
                            inputSize,
                            outputBytes,
                            &outputSize
                        )
                    }
                }
            }
        }

        guard result == kIOReturnSuccess else {
            throw SMCError.callFailed(operation, result)
        }
    }
}

func fourCC(_ string: String) throws -> UInt32 {
    let scalars = Array(string.utf8)
    guard scalars.count == 4 else {
        throw SMCError.invalidKey(string)
    }
    return scalars.reduce(UInt32(0)) { ($0 << 8) + UInt32($1) }
}

func fourCCString(_ value: UInt32) -> String {
    let bytes = [
        UInt8((value >> 24) & 0xff),
        UInt8((value >> 16) & 0xff),
        UInt8((value >> 8) & 0xff),
        UInt8(value & 0xff)
    ]
    return String(bytes: bytes, encoding: .ascii) ?? "????"
}

func decodeUInt16(_ bytes: [UInt8]) -> UInt16 {
    UInt16(bytes[0]) << 8 | UInt16(bytes[1])
}

func decodeUInt32(_ bytes: [UInt8]) -> UInt32 {
    UInt32(bytes[0]) << 24 | UInt32(bytes[1]) << 16 | UInt32(bytes[2]) << 8 | UInt32(bytes[3])
}

func encodeUInt16(_ value: UInt16) -> [UInt8] {
    [UInt8((value >> 8) & 0xff), UInt8(value & 0xff)]
}

func decodeFPE2(_ bytes: [UInt8]) -> Double {
    Double(decodeUInt16(bytes)) / 4.0
}

func encodeFPE2(_ value: Double) -> [UInt8] {
    encodeUInt16(UInt16((value * 4.0).rounded()))
}

func decodeSP78(_ bytes: [UInt8]) -> Double {
    let raw = Int16(bitPattern: decodeUInt16(bytes))
    return Double(raw) / 256.0
}

private func tupleToArray(
    _ tuple: (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    ),
    count: Int
) -> [UInt8] {
    withUnsafeBytes(of: tuple) { Array($0.prefix(count)) }
}

private func arrayToTuple(
    _ bytes: [UInt8]
) -> (
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
) {
    var padded = bytes + Array(repeating: UInt8(0), count: max(0, 32 - bytes.count))
    padded = Array(padded.prefix(32))
    return (
        padded[0], padded[1], padded[2], padded[3], padded[4], padded[5], padded[6], padded[7],
        padded[8], padded[9], padded[10], padded[11], padded[12], padded[13], padded[14], padded[15],
        padded[16], padded[17], padded[18], padded[19], padded[20], padded[21], padded[22], padded[23],
        padded[24], padded[25], padded[26], padded[27], padded[28], padded[29], padded[30], padded[31]
    )
}

private func machError(_ code: kern_return_t) -> String {
    if let text = String(validatingCString: mach_error_string(code)) {
        return "\(text) (\(code))"
    }
    return "\(code)"
}
