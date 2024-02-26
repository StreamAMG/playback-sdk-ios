Playback SDK
------------

This library simplifies integrating video playback functionalities into OTT applications. It provides a unified interface for interacting with video APIs and managing playback logic.

**Key Features:**

-   **Abstraction:** Hides the complexities of underlying video APIs, allowing you to focus on the core playback experience.
-   **Flexibility:** Supports different video providers and allows the creation of custom playback plugins for extended functionalities.
-   **Error Handling:** Provides mechanisms to handle potential issues during playback and notify your application.

**Supported Platforms and Version**

- Platforms: iOS 14 and later
- Swift Package Manager:

**Installation**

1.  Add the Playback SDK dependency to your project using Swift Package Manager.

Swift

```
dependencies: [
    .package(url: "https://github.com/your-organization/playback-sdk.git", .branch("master"))
]

```

1.  Import the `PlaybackSDK` module in your Swift files.

Swift

```
import PlaybackSDK

```

**Usage**

1.  **Initialization:**

Swift

```
PlaybackSDKManager.shared.initialize(apiKey: "YOUR_API_KEY") { result in
    switch result {
    case .success:
        print("Playback SDK initialized successfully.")
    case .failure(let error):
        print("Error initializing Playback SDK: \(error)")
    }
}

```

1.  **Loading HLS Stream:**

Swift

```
let entryId = "YOUR_ENTRY_ID"
let authorizationToken = "YOUR_AUTHORIZATION_TOKEN" (optional)

VideoPlayerWrapper(entryId: entryId, authorizationToken: authorizationToken)

```

**Video Player Plugins (Optional)**

The Playback SDK supports extending functionalities through custom video player plugins. These plugins can provide extended functionalities or integrate with third-party video players. Refer to the full source code for details on creating custom plugins.

```
// Implement your custom player plugin conforming to VideoPlayerPlugin protocol

// Register your custom plugin with the manager
let pluginManager = VideoPlayerPluginManager.shared
pluginManager.registerPlugin(YourCustomPlayerPlugin())
// Use the selected plugin for playback
pluginManager.selectedPlugin?.play()
```

**Error Handling**

The library propagates errors through completion handlers. You can handle these errors to provide appropriate feedback to the user.

**Example**

Swift

```
PlaybackSDKManager.shared.initialize(apiKey: "YOUR_API_KEY") { result in
    switch result {
    case .success:
        print("Playback SDK initialized successfully.")

        let entryId = "YOUR_ENTRY_ID"
        let authorizationToken = "YOUR_AUTHORIZATION_TOKEN" (optional)

        VideoPlayerWrapper(entryId: entryId, authorizationToken: authorizationToken)
    case .failure(let error):
        print("Error initializing Playback SDK: \(error)")
    }
}

```