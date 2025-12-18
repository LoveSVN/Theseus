// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Theseus",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Theseus",
            targets: ["Theseus"]
        ),
    ],
    targets: [
        .target(
            name: "Theseus",
            resources: [
                .process("Shaders")
            ],
            linkerSettings: [
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("IOSurface")
            ]
        ),
        .testTarget(
            name: "TheseusTests",
            dependencies: ["Theseus"]
        ),
    ]
)
