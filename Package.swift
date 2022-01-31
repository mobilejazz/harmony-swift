// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Harmony",
    platforms: [.iOS(.v12),
                .macOS(.v10_12)],
    products: [
        .library(
            name: "Harmony",
            targets: ["Harmony"]
        ),
        .library(
            name: "HarmonyAlamofire",
            targets: ["HarmonyAlamofire"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            .exact("4.8.2")
        )
    ],
    targets: [
        .target(
            name: "Harmony",
            dependencies: [],
            path: "Sources/Core"
        ),
        .target(
            name: "HarmonyAlamofire",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .target(name: "Harmony"),
            ],
            path: "Sources/Alamofire"
        ),
        .testTarget(
            name: "HarmonyTests",
            dependencies: ["Harmony"]
        )
    ]
)
