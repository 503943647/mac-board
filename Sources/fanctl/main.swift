import Foundation
import FanCore

let command = CommandLine.arguments.dropFirst()

func printUsage() {
    print("""
    fanctl - Mac fan and temperature control

    Usage:
      fanctl status
      fanctl temps
      fanctl fans
      fanctl system
      fanctl max
      fanctl manual <fan-index> <rpm>
      fanctl keys [prefix]
      fanctl raw <smc-key>

    Examples:
      fanctl status
      sudo fanctl max
      sudo fanctl manual 0 3600
      sudo fanctl system

    Notes:
      Write commands usually require sudo.
      Fan control is hardware-sensitive; stay within the reported min/max RPM range.
    """)
}

func formatRPM(_ value: Double?) -> String {
    guard let value else {
        return "-"
    }
    return "\(Int(value.rounded())) RPM"
}

func run() throws {
    guard let verb = command.first else {
        printUsage()
        return
    }

    if verb == "-h" || verb == "--help" || verb == "help" {
        printUsage()
        return
    }

    let smc = try SMC()
    let controller = FanController(smc: smc)

    switch verb {
    case "status":
        try printFans(controller)
        print("")
        try printTemperatures(controller)
    case "temps", "temperatures":
        try printTemperatures(controller)
    case "fans":
        try printFans(controller)
    case "system", "auto":
        try controller.setSystemMode()
        print("Fan control returned to the system controller.")
    case "max":
        try controller.setMaxMode()
        print("All detected fans were set to maximum RPM.")
    case "manual":
        let args = Array(command)
        guard args.count == 3, let index = Int(args[1]), let rpm = Double(args[2]) else {
            throw CLIError.invalidArguments("Usage: sudo fanctl manual <fan-index> <rpm>")
        }
        try controller.setManual(fanIndex: index, rpm: rpm)
        print("Fan \(index) target set to \(Int(rpm)) RPM.")
    case "keys":
        let prefix = command.count > 1 ? String(command[command.index(after: command.startIndex)]) : nil
        for key in try controller.listSMCKeys(prefix: prefix) {
            print(key)
        }
    case "raw":
        let args = Array(command)
        guard args.count == 2 else {
            throw CLIError.invalidArguments("Usage: fanctl raw <smc-key>")
        }
        let value = try smc.read(args[1])
        let bytes = value.bytes.map { String(format: "%02x", $0) }.joined(separator: " ")
        print("\(value.key) \(value.dataType) [\(bytes)]")
    default:
        throw CLIError.invalidArguments("Unknown command: \(verb)")
    }
}

func printFans(_ controller: FanController) throws {
    let fans = try controller.fans()
    print("Fans")
    if fans.isEmpty {
        print("  No fans detected.")
        return
    }

    for fan in fans {
        let mode = fan.forced ? "manual" : "system"
        print("  Fan \(fan.index): \(formatRPM(fan.actualRPM)) actual, \(formatRPM(fan.targetRPM)) target, \(mode)")
        print("    Range: \(formatRPM(fan.minRPM)) - \(formatRPM(fan.maxRPM))")
    }
}

func printTemperatures(_ controller: FanController) throws {
    let readings = try controller.temperatures()
    print("Temperatures")
    if readings.isEmpty {
        print("  No temperature sensors were readable through AppleSMC.")
        return
    }

    for reading in readings {
        print("  \(reading.name): \(Int(reading.celsius.rounded()))℃ [\(reading.key)]")
    }
}

enum CLIError: Error, CustomStringConvertible {
    case invalidArguments(String)

    var description: String {
        switch self {
        case .invalidArguments(let message):
            return message
        }
    }
}

do {
    try run()
} catch let error as CustomStringConvertible {
    fputs("Error: \(error.description)\n", stderr)
    exit(1)
} catch {
    fputs("Error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
