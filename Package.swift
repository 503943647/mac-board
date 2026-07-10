// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FanController",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "fanctl", targets: ["fanctl"]),
        .executable(name: "fanmenu", targets: ["fanmenu"]),
        .executable(name: "fanhelper", targets: ["fanhelper"])
    ],
    targets: [
        .target(
            name: "FanCore",
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        ),
        .executableTarget(
            name: "fanctl",
            dependencies: ["FanCore"]
        ),
        .executableTarget(
            name: "fanmenu",
            dependencies: ["FanCore"],
            linkerSettings: [
                .linkedFramework("AppKit")
            ]
        ),
        .executableTarget(
            name: "fanhelper",
            dependencies: ["FanCore"]
        )
    ]
)
