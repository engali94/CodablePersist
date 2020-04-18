// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CodablePersist",
    platforms: [
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "CodablePersist",
            targets: ["CodablePersist"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CodablePersist",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "CodablePersistTests",
            dependencies: ["CodablePersist"],
            path: "Tests"
        ),
    ]
)
