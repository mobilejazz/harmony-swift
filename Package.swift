// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Harmony",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Harmony",
            targets: ["Harmony"]
        ),
        .library(
            name: "HarmonyTesting",
            targets: ["HarmonyTesting"]
        ),
    ],
    targets: [
        .target(
            name: "Harmony",
            dependencies: []
        ),
        .target(
            name: "HarmonyTesting",
            dependencies: [.target(name: "Harmony")]
        ),
        .testTarget(
            name: "HarmonyTests",
            dependencies: ["Harmony"]
        ),
    ]
)
