// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlaybackSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PlaybackSDK",
            targets: ["PlaybackSDK"]
        ),
    ],
    
    dependencies: [
        // Declare dependencies
        
        // BitmovinPlayer
        .package(url: "https://github.com/bitmovin/player-ios.git",
                 revision: "3.56.1"),

        // other dependencies
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PlaybackSDK",
            dependencies: [
                .product(name: "BitmovinPlayer", package: "player-ios"),
            ]
        ),
        .testTarget(
            name: "PlaybackSDKTests",
            dependencies: ["PlaybackSDK"]),
    ]
)
