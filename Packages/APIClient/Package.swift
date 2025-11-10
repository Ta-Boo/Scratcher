// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "APIClient",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "APIClient",
            targets: ["APIClient"]),
    ],
    dependencies: [
        // Reference the local Logger package
        .package(path: "../Logger"),
    ],
    targets: [
        .target(
            name: "APIClient",
            dependencies: [
                .product(name: "Logger", package: "Logger")
            ]),
        .testTarget(
            name: "APIClientTests",
            dependencies: ["APIClient"]),
    ]
)
