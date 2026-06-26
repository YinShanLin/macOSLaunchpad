// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ApplicationsCenter",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ApplicationsCenter",
            path: "Sources/ApplicationsCenter"
        )
    ]
)
