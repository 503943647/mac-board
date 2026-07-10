import Darwin
import FanCore
import Foundation

private let socketPath = "/var/run/fancontroller.sock"
private let helperProtocolVersion = "2026-07-08.2"

@discardableResult
private func checked(_ result: Int32, _ message: String) -> Int32 {
    if result == -1 {
        perror(message)
        exit(1)
    }
    return result
}

private func handle(_ command: String) -> String {
    let parts = command.split(separator: " ").map(String.init)
    guard let verb = parts.first else {
        return "ERR empty command\n"
    }

    do {
        let controller = FanController(smc: try SMC())
        switch verb {
        case "system":
            try controller.setSystemMode()
            return "OK system\n"
        case "max":
            try controller.setMaxMode()
            return "OK max\n"
        case "manual":
            guard parts.count == 3, let fan = Int(parts[1]), let rpm = Double(parts[2]) else {
                return "ERR usage manual <fan> <rpm>\n"
            }
            try controller.setManual(fanIndex: fan, rpm: rpm)
            return "OK manual\n"
        case "manual-all":
            guard parts.count == 2, let rpm = Double(parts[1]) else {
                return "ERR usage manual-all <rpm>\n"
            }
            try controller.setManualAll(rpm: rpm)
            return "OK manual-all\n"
        case "ping":
            return "OK pong\n"
        case "version":
            return "OK fanhelper \(helperProtocolVersion)\n"
        default:
            return "ERR unknown command\n"
        }
    } catch let error as CustomStringConvertible {
        return "ERR \(error.description)\n"
    } catch {
        return "ERR \(error.localizedDescription)\n"
    }
}

unlink(socketPath)

let server = checked(socket(AF_UNIX, SOCK_STREAM, 0), "socket")
var address = sockaddr_un()
address.sun_family = sa_family_t(AF_UNIX)
withUnsafeMutableBytes(of: &address.sun_path) { rawBuffer in
    let bytes = Array(socketPath.utf8.prefix(rawBuffer.count - 1))
    rawBuffer.copyBytes(from: bytes)
}

let bindResult = withUnsafePointer(to: &address) { pointer in
    pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
        bind(server, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_un>.size))
    }
}
checked(bindResult, "bind")
chmod(socketPath, 0o666)
checked(listen(server, 8), "listen")

while true {
    let client = accept(server, nil, nil)
    if client == -1 {
        continue
    }

    var buffer = [UInt8](repeating: 0, count: 256)
    let count = read(client, &buffer, buffer.count - 1)
    if count > 0 {
        let command = String(decoding: buffer.prefix(Int(count)), as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let response = handle(command)
        _ = response.withCString { write(client, $0, strlen($0)) }
    }
    close(client)
}
