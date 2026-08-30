// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftLanguageGuideExtended",
    products: [
        .library(name: "SwiftLanguageGuideExtended", targets: ["SwiftLanguageGuideExtended"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.4.0"),
    ],
    targets: [
        .target(name: "SwiftLanguageGuideExtended"),
    ]
)
