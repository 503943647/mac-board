import Foundation

enum SensorNames {
    static let commonTemperatureKeys = [
        "TC0P", "TC0E", "TC0F", "TC0H",
        "TC1C", "TC2C", "TC3C", "TC4C", "TC5C", "TC6C", "TC7C", "TC8C", "TC9C",
        "Tp01", "Tp05", "Tp09", "Tp0D", "Tp0H", "Tp0L", "Tp0P", "Tp0T", "Tp0X",
        "Tg05", "Tg0D", "Tg0P",
        "TB0T", "TB1T", "TB2T",
        "TW0P", "Tm0P", "Ts0P", "TN0P", "Th0H"
    ]

    static func name(for key: String) -> String {
        if let known = knownNames[key] {
            return known
        }

        if key.hasPrefix("TC") {
            return "CPU"
        }
        if key.hasPrefix("Tp") {
            return "Performance Core"
        }
        if key.hasPrefix("Te") {
            return "Efficiency Core"
        }
        if key.hasPrefix("Tg") {
            return "GPU"
        }
        if key.hasPrefix("TB") {
            return "Battery"
        }
        if key.hasPrefix("TW") {
            return "Wireless"
        }
        if key.hasPrefix("Tm") {
            return "Memory"
        }
        if key.hasPrefix("Th") {
            return "Thunderbolt"
        }
        return "Sensor"
    }

    private static let knownNames: [String: String] = [
        "TC0P": "CPU Proximity",
        "TC0E": "CPU",
        "TC0F": "CPU Fan",
        "TC0H": "CPU Heatsink",
        "TC1C": "CPU Core 1",
        "TC2C": "CPU Core 2",
        "TC3C": "CPU Core 3",
        "TC4C": "CPU Core 4",
        "TC5C": "CPU Core 5",
        "TC6C": "CPU Core 6",
        "TC7C": "CPU Core 7",
        "TC8C": "CPU Core 8",
        "TC9C": "CPU Core 9",
        "Tg0P": "GPU Proximity",
        "Tg05": "GPU Cluster",
        "Tg0D": "GPU",
        "TB0T": "Battery",
        "TB1T": "Battery",
        "TB2T": "Battery",
        "TW0P": "Wireless Proximity",
        "Tm0P": "Memory Proximity",
        "Ts0P": "SSD Proximity",
        "TN0P": "SSD NAND",
        "Th0H": "Thunderbolt Proximity"
    ]
}
