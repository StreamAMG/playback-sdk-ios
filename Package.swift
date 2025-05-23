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
        .package(
            name: "BitmovinPlayer",
            url: "https://github.com/bitmovin/player-ios.git",
            .exact("3.84.0")
        ),

        // other dependencies
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PlaybackSDK",
            dependencies: [
                .product(name: "BitmovinPlayer", package: "BitmovinPlayer"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
                .copy("Resources/bitmovinplayer-ui.min.css"),
                .copy("Resources/bitmovinplayer-ui.min.js")
            ]
        ),
        .testTarget(
            name: "PlaybackSDKTests",
            dependencies: ["PlaybackSDK"],
            exclude: ["Folder Structure.md"], // Exclude non-Swift test files if needed
            swiftSettings: [
                // Set the swift settings specifically for iOS platform
                .define("iOS_TEST", .when(platforms: [.iOS])),
            ]),
    ]
)
