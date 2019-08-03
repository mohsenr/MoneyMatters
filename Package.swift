// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MoneyMatters",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Accountant",
            targets: ["Accountant"]
        ),
        .library(
            name: "ForeignExchange",
            targets: ["ForeignExchange"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/zuhlke/Support.git", .upToNextMajor(from: "1.0.1")),
    ],
    targets: [
        .target(
            name: "Accountant",
            dependencies: ["Support"]
        ),
        .target(
            name: "ForeignExchange",
            dependencies: ["Support"]
        ),
        .testTarget(
            name: "AccountantTests",
            dependencies: ["Accountant", "TestingSupport"]
        ),
        .testTarget(
            name: "ForeignExchangeTests",
            dependencies: ["ForeignExchange"]
        ),
    ]
)
