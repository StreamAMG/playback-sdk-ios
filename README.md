# Playback SDK iOS

---

[![Swift](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/swift.yml/badge.svg)](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/swift.yml)

[![pages-build-deployment](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/pages/pages-build-deployment)

This library simplifies integrating video playback functionalities into OTT applications. It provides a unified interface for interacting with video APIs and managing playback logic.

**Key Features:**

- **Abstraction:** Hides the complexities of underlying video APIs, allowing you to focus on the core playback experience.
- **Flexibility:** Supports different video providers and allows the creation of custom playback plugins for extended functionalities.
- **Error Handling:** Provides mechanisms to handle potential issues during playback and notify your application.

**Supported Platforms and Version**

- Platforms: iOS 14 and later

**Getting Started**

To initialize the SDK, you will need an **API key**, which can be obtained by contacting your StreamAMG account manager. Additionally, to use the playback default plugin, your app needs to be **whitelisted**. Please communicate the bundle ID of your app to your StreamAMG account manager for whitelisting.

Once you have obtained the API key and your app has been whitelisted, you can proceed with the initialisation of the SDK in your project.

**Installation**

1. Add the Playback SDK dependency to your project using Swift Package Manager.

Swift

```
dependencies: [
    .package(url: "https://github.com/StreamAMG/playback-sdk-ios", .branch("main"))
]

```

2. Import the `PlaybackSDK` module in your Swift files.

Swift

```
import PlaybackSDK

```

## PlaybackSDKManager

The `PlaybackSDKManager` is a singleton object designed to manage the functionalities of the playback SDK. It provides methods for initialization, loading player UI, and loading HLS streams.

## Initialization

To initialize the playback SDK, use the `initialize` method of the `PlaybackSDKManager` singleton object. This method requires an API key for authentication. Optionally, you can specify a base URL for the playback API.

Example:

```swift
    // Initialize SDK with the settings
    PlaybackSDKManager.shared.initialize(apiKey: "<API_KEY>", baseURL: "<BASE_URL>") { result ->
        // Register default layer plugin 

        switch result {
        case .success(let license):
            let customPlugin = BitmovinPlayerPlugin()
            
            // Setting up player plugin
            var config = VideoPlayerConfig()
            config.playbackConfig.autoplayEnabled = true // Toggle autoplay
            config.playbackConfig.backgroundPlaybackEnabled = true // Toggle background playback
            customPlugin.setup(config: config)
            
            VideoPlayerPluginManager.shared.registerPlugin(customPlugin)
        case .failure(let error):
            // Handle error
        }
    }
```

## Loading Player UI

To load the player UI in your application, use the `loadPlayer` method of the `PlaybackSDKManager` singleton object. This method is a Composable function that you can use to load and render the player UI.

Example:

```swift
PlaybackSDKManager.shared.loadPlayer(
    entryID: entryId,
    authorizationToken: authorizationToken
) { error in
    // Handle player UI error 
} 
```

## Loading a Playlist

To load a sequential list of videos into the player UI, use the `loadPlaylist` method of the `PlaybackSDKManager` singleton object. This method is a Composable function that you can use to load and render the player UI.
`entryIDs`: An array of Strings containing the unique identifiers of all the videos in the playlist.
`entryIDToPlay`: (Optional) Specifies the unique video identifier that will be played first in the playlist. If not provided, the first video in the `entryIDs` array will be played.

Example:

```swift
PlaybackSDKManager.shared.loadPlaylist(
    entryIDs: listEntryId,
    entryIDToPlay: "0_xxxxxxxx",
    authorizationToken: authorizationToken
) { errors in
    // Handle player UI playlist errors
} 
```

### Controlling Playlist Playback

To control playlist playback, declare a VideoPlayerPluginManager singleton instance as a @StateObject variable. This allows you to access various control functions and retrieve information about the current playback state.

Here are some of the key functions you can utilize:

`playFirst()`: Plays the first video in the playlist.
`playPrevious()`: Plays the previous video in the playlist.
`playNext()`: Plays the next video in the playlist.
`playLast()`: Plays the last video in the playlist.
`seek(entryIdToSeek)`: Seek a specific video Id
`activeEntryId()`: Returns the unique identifier of the currently playing video.

By effectively leveraging these functions, you can create dynamic and interactive video player experiences.

Example:

```swift
@StateObject private var pluginManager = VideoPlayerPluginManager.shared
...
// You can use the following playlist controls
pluginManager.selectedPlugin?.playFirst() // Play the first video
pluginManager.selectedPlugin?.playPrevious() // Play the previous video
pluginManager.selectedPlugin?.playNext() // Play the next video
pluginManager.selectedPlugin?.playLast() // Play the last video
pluginManager.selectedPlugin?.seek(entryIdToSeek) { success in // Seek a specific video
    if (!success) {
        let errorMessage = "Unable to seek video Id \(entryIdToSeek)"
    }
}
pluginManager.selectedPlugin?.activeEntryId() // Get the active video Id
```

### Receiving Playlist Events

To receive playlist events, declare a VideoPlayerPluginManager singleton instance, similar to how you did in the Controlling Playlist Playback section.
Utilize the `onReceive` modifier to listen for player events, such as the `PlaylistTransitionEvent`. This event provides information about the transition from one video to another.

Example:

```swift
@StateObject private var pluginManager = VideoPlayerPluginManager.shared
...
PlaybackSDKManager.shared.loadPlaylist(
    entryIDs: entryIDs,
    entryIDToPlay: entryIDToPlay,
    authorizationToken: authorizationToken
) { errors in
        ...
}
.onReceive(pluginManager.selectedPlugin!.event) { event in
    if let event = event as? PlaylistTransitionEvent { // Playlist Event
        if let from = event.from.metadata?["entryId"], let to = event.to.metadata?["entryId"] {
            print("Playlist event changed from \(from) to \(to)")
        }
    }
}
```

## Playing Access-Controlled Content

To play on-demand and live videos that require authorization, at some point before loading the player your app must call CloudPay to start session, passing the authorization token:

```swift
"\(baseURL)/sso/start?token=\(authorizationToken)"
```

Then the same token should be passed into the `loadPlayer(entryID:, authorizationToken:)` method of `PlaybackSDkManager`.
For the free videos that user should be able to watch without logging in, starting the session is not required and `authorizationToken` can be set to an empty string.

> \[!NOTE]
> If the user is authenticated, has enough access level to watch a video, the session was started and the same token was passed to the player but the videos still throw a 401 error, it might be related to these requests having different user-agent headers.

## Configure user-agent

Sometimes a custom `user-agent` header is automatically set for the requests on iOS when creating a token and starting a session. `Alamofire` and other 3rd party networking frameworks can modify this header to include information about themselves. In such cases they should either be configured to not modify the header, or the custom header should be passed to the player as well.

Example:

```swift
PlaybackSDKManager.shared.initialize(
    apiKey: apiKey,
    baseURL: baseURL,
    userAgent: customUserAgent
) { result in
    // Handle player UI error
}
```

By default the SDK uses system user agent, so if your app uses native URL Session, the `userAgent` parameter most likely can be omitted.

## Bitmovin analytics

Currently SDK support tracking analytics on Bitmovin service. In case you have a logged-in user and want to track Bitmovin analytics for the current session, you need to pass the user's ID in the `analyticsViewerId` parameter.

Example: 

```swift
    let entryId = "..."
    let authorizationToken = "..."
    let analyticsViewerId = "user id or empty string"
    
    /// ** Load player with the playback SDK **
    PlayBackSDKManager.shared.loadPlayer(entryID: entryId,
                                            authorizationToken: authorizationToken,
                                            mediaTitle: "Background audio test",
                                            analyticsViewerId: analyticsViewerId,
                                            onError: {
        error in
        // Handle the error here
        
        switch error {
        case .apiError(let statusCode, let message, let reason):
            let errorMessage = "\(message) Status Code \(statusCode), Reason: \(reason)"
            print(errorMessage)
            self.errorMessage = errorMessage
        default:
            print("Error loading HLS stream in PlaybackUIView: \(error.localizedDescription)")
            errorMessage = "Error code and errorrMessage not found: \(error.localizedDescription)"
        }
        
    })
```

## Resources

- **Tutorial:** [Tutorial](https://streamamg.github.io/playback-sdk-ios/tutorials/table-of-contents/#resources)
- **Demo app:** [GitHub Repository](https://github.com/StreamAMG/playback-demo-ios)
- **Stoplight API documentation:** [Documentation](https://streamamg.stoplight.io)

**Collaboration:**

To update the documentation, follow these steps:

1. Make changes to the documentation code.
2. Build the documentation by running the convenience script from the root of this repository.
   ```sh
   ./generate_docc
   ```
   or
   ```sh
   sh generate_docc
   ```
   Alternatively, follow the instructions at [this URL](https://swiftlang.github.io/swift-docc-plugin/documentation/swiftdoccplugin/publishing-to-github-pages/).
3. Commit and push the changes onto your branch.
4. Go to [GitHub Pages settings](https://github.com/StreamAMG/playback-sdk-ios/settings/pages), change the Branch in `Build and deployment` section to your branch and press "Save".
5. After merging, redo step 4 to re-deploy the documentation from the branch where it was merged to.
