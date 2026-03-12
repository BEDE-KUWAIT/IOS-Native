// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BedeSdk",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BedeSdk",
            targets: ["BedeSdk"]
        ),
    ],
    targets: [
        .target(
            name: "BedeSdk",
            path: "bede-ios-sdk/BedeSdk",
            exclude: ["BedeSdk.docc"]
        ),
    ]
)