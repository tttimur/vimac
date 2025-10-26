// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VimacModern",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VimacModern",
            targets: ["VimacModern"]
        )
    ],
    dependencies: [
        // Zero external dependencies! ✨
    ],
    targets: [
        .executableTarget(
            name: "VimacModern",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
