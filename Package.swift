// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Timeline",
    products: [
        .library(name: "Timeline", targets: ["Timeline"]),
    ],
    dependencies: [
        .package(url: "https://github.com/dn-m/Structure", .branch("master")),
        .package(url: "https://github.com/dn-m/Math", .branch("master"))
    ],
    targets: [
        // Sources
        .target(name: "Timeline", dependencies: ["DataStructures", "Math"]),

        // Tests
        .testTarget(name: "TimelineTests", dependencies: ["Timeline"]),
    ]
)
