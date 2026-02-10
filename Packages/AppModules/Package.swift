// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppModules",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Core", targets: ["Core"]),
        .library(name: "FeatureDailyPuzzle", targets: ["FeatureDailyPuzzle"]),
        .library(name: "FeatureHistory", targets: ["FeatureHistory"]),
        .library(name: "FeatureSettings", targets: ["FeatureSettings"])
    ],
    targets: [
        .target(
            name: "DesignSystem",
            path: "Sources/DesignSystem"
        ),
        .target(
            name: "Core",
            path: "Sources/Core",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "FeatureDailyPuzzle",
            dependencies: ["Core", "DesignSystem"],
            path: "Sources/FeatureDailyPuzzle",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "FeatureHistory",
            dependencies: ["Core", "DesignSystem"],
            path: "Sources/FeatureHistory",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "FeatureSettings",
            dependencies: ["Core", "DesignSystem"],
            path: "Sources/FeatureSettings",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests/CoreTests"
        ),
        .testTarget(
            name: "FeatureDailyPuzzleTests",
            dependencies: ["FeatureDailyPuzzle", "Core"],
            path: "Tests/FeatureDailyPuzzleTests"
        ),
        .testTarget(
            name: "FeatureHistoryTests",
            dependencies: ["FeatureHistory"],
            path: "Tests/FeatureHistoryTests"
        ),
        .testTarget(
            name: "FeatureSettingsTests",
            dependencies: ["FeatureSettings"],
            path: "Tests/FeatureSettingsTests"
        )
    ]
)
