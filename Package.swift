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
        
        /// Firebase
        .package(name: "Firebase",
                 url: "https://github.com/firebase/firebase-ios-sdk.git",
                 from: "10.12.0"),
        
        // BitmovinPlayer
        .package(name: "BitmovinPlayer",
                 url: "https://github.com/bitmovin/player-ios.git",
                 .exact("3.56.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PlaybackSDK",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "Firebase"),
                .product(name: "FirebaseCrashlytics", package: "Firebase"),
                .product(name: "FirebasePerformance", package: "Firebase"),
                .product(name: "FirebaseMessaging", package: "Firebase"),
                .product(name: "FirebaseStorage", package: "Firebase"),
                .product(name: "BitmovinPlayer", package: "BitmovinPlayer"),
                
                // ...
              ]
            ),
        .testTarget(
            name: "PlaybackSDKTests",
            dependencies: ["PlaybackSDK"]),
    ]
)
