Playback SDK
------------

[![Swift](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/swift.yml/badge.svg)](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/swift.yml)

[![pages-build-deployment](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/pages/pages-build-deployment)

This library simplifies integrating video playback functionalities into OTT applications. It provides a unified interface for interacting with video APIs and managing playback logic.

**Key Features:**

-   **Abstraction:** Hides the complexities of underlying video APIs, allowing you to focus on the core playback experience.
-   **Flexibility:** Supports different video providers and allows the creation of custom playback plugins for extended functionalities.
-   **Error Handling:** Provides mechanisms to handle potential issues during playback and notify your application.

**Supported Platforms and Version**

- Platforms: iOS 14 and later

**Getting Started**

To initialize the SDK, you will need an **API key**, which can be obtained by contacting your StreamAMG account manager. Additionally, to use the playback default plugin, your app needs to be **whitelisted**. Please communicate the bundle ID of your app to your StreamAMG account manager for whitelisting.

Once you have obtained the API key and your app has been whitelisted, you can proceed with the initialisation of the SDK in your project.


**Installation**

1.  Add the Playback SDK dependency to your project using Swift Package Manager.

Swift

```
dependencies: [
    .package(url: "https://github.com/StreamAMG/playback-sdk-ios", .branch("main"))
]

```

2.  Import the `PlaybackSDK` module in your Swift files.

Swift

```
import PlaybackSDK

```
# PlaybackSDKManager

The `PlaybackSDKManager` is a singleton object designed to manage the functionalities of the playback SDK. It provides methods for initialization, loading player UI, and loading HLS streams.

# Initialization

To initialize the playback SDK, use the `initialize` method of the `PlaybackSDKManager` singleton object. This method requires an API key for authentication. Optionally, you can specify a base URL for the playback API.

Example:

```swift
    // Initialize SDK with the settings
    PlaybackSDKManager.shared.initialize(apiKey: "<API_KEY>", baseURL: "<BASE_URL>") { result ->
        // Register default layer plugin 

        switch result {
        case .success(let license):
            val customPlugin = BitmovinVideoPlayerPlugin()
            VideoPlayerPluginManager.shared.registerPlugin(customPlugin)
        case .failure(let error):
            // Handle error
        }
    }
```


# Loading Player UI

To load the player UI in your application, use the `loadPlayer` method of the `PlaybackSDKManager` singleton object. This method is a Composable function that you can use to load and render the player UI.

Example:

```swift
PlayBackSDKManager.shared.loadPlayer(entryID: entryId, authorizationToken: authorizationToken) { error in
    // Handle player UI error 
} 
```

# Playing Access-Controlled Content
To play premium or freemium on-demand and live videos, an `authorizationToken` has to be passed into the player. 
Before loading the player, a call to CloudPay to start session must be made with the same token.
```swift
"\(baseURL)/sso/start?token=\(authorizationToken)"
```
In case a custom `user-agent` header is set for the request when creating a token, it should be passed to the player as well.  

Example:

```swift
PlayBackSDKManager.shared.initialize(apiKey: apiKey, baseURL: baseURL, userAgent: customUserAgent) { result in 
    // Handle player UI error 
} 
```


**Resources:**

- **Tutorial:** [Tutorial](https://streamamg.github.io/playback-sdk-ios/tutorials/table-of-contents/#resources)
- **Demo app:** [GitHub Repository](https://github.com/StreamAMG/playback-demo-ios)
- **Stoplight API documentation:** [Documentation](https://streamamg.stoplight.io)

**Collaboration:**

To update the documentation, follow these steps:

1. Make changes to the documentation code.
2. Build the documentation following the instructions in [this URL](https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/publishing-to-github-pages/).
3. Merge the code into the `gh-pages` branch.

