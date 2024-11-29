// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "VADefaults",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "VADefaults",
            targets: ["VADefaults"]
        ),
        .executable(
            name: "VADefaultsClient",
            targets: ["VADefaultsClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        .macro(
            name: "VADefaultsMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "VADefaults", dependencies: ["VADefaultsMacros"]),
        .executableTarget(name: "VADefaultsClient", dependencies: ["VADefaults"]),
        .testTarget(
            name: "VADefaultsTests",
            dependencies: [
                "VADefaultsMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageVersions: [.version("6")]
)
