// swift-tools-version: 6.2
import PackageDescription

var targets: [Target] = [
    .target(name: "SwiftLanguageGuideExtended"),
]

// Objective-C needs an Apple toolchain, and the docs build runs on Linux with
// plain `swift build`, which would compile a library target. Everything that
// is or depends on Objective-C is added only where it can build.
#if canImport(ObjectiveC)
targets += [
    .target(name: "SwiftLanguageGuideExtendedObjC"),
    .testTarget(
        name: "SwiftLanguageGuideExtendedTests",
        dependencies: ["SwiftLanguageGuideExtended", "SwiftLanguageGuideExtendedObjC"]
    ),
    .testTarget(
        name: "SwiftLanguageGuideExtendedTestsObjC",
        dependencies: ["SwiftLanguageGuideExtendedObjC"]
    ),
]
#else
targets.append(
    .testTarget(
        name: "SwiftLanguageGuideExtendedTests",
        dependencies: ["SwiftLanguageGuideExtended"]
    )
)
#endif

let package = Package(
    name: "SwiftLanguageGuideExtended",
    platforms: [
        // Below iOS 26, so the availability experiments in the test targets
        // exercise real run-time checks rather than constants.
        .iOS(.v17),
    ],
    products: [
        .library(name: "SwiftLanguageGuideExtended", targets: ["SwiftLanguageGuideExtended"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.4.0"),
    ],
    targets: targets
)
