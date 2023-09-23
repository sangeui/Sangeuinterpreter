// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "main",
    products: [
        .executable(name: "main", targets: ["Main"])
    ],
    targets: [
        .target(
            name: "Sangeuinterpreter"),
        .executableTarget(name: "Main", dependencies: ["Sangeuinterpreter"]),
    ]
)
