// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftLanguageGuideExtended",
    platforms: [
        // Below iOS 26, so the availability experiments in the test target
        // exercise real run-time checks rather than constants.
        .iOS(.v17),
    ],
    products: [
        .library(name: "SwiftLanguageGuideExtended", targets: ["SwiftLanguageGuideExtended"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.4.0"),
    ],
    targets: [
        .target(name: "SwiftLanguageGuideExtended"),
        .testTarget(
            name: "SwiftLanguageGuideExtendedTests",
            dependencies: ["SwiftLanguageGuideExtended"]
        ),
    ]
)
