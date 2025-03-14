# Playback SDK iOS

---

[![Swift](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/swift.yml/badge.svg)](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/swift.yml)

[![pages-build-deployment](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/pages/pages-build-deployment)

This library simplifies integrating video playback functionalities into OTT applications. It provides a unified interface for interacting with video APIs and managing playback logic.

**Key Features:**

- **Abstraction:** Hides the complexities of underlying video APIs, allowing you to focus on the core playback experience.
- **Flexibility:** Supports different video providers and allows the creation of custom playback plugins for extended functionalities.
- **Error Handling:** Provides mechanisms to handle potential issues during playback and notify your application.

## Getting Started

### Supported Platforms and Version

- Platforms: iOS 14 and later

To initialize the SDK, you will need an **API key**, which can be obtained by contacting your StreamAMG account manager. Additionally, to use the playback default plugin, your app needs to be **whitelisted**. Please communicate the bundle ID of your app to your StreamAMG account manager for whitelisting.

Once you have obtained the API key and your app has been whitelisted, you can proceed with the initialisation of the SDK in your project.

### Installation

1. Add the Playback SDK dependency to your project using Swift Package Manager.

```swift
dependencies: [
    .package(url: "https://github.com/StreamAMG/playback-sdk-ios", .branch("main"))
]
```

2. Import the `PlaybackSDK` module in your Swift files.

```swift
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
        // Handle error as SDKError
    }
}
```
**Error Handling:** For information on handling potential errors during playlist loading, see the [Error Handling](#error-handling) section.


## Loading Player UI

To load the player UI in your application, use the `loadPlayer` method of the `PlaybackSDKManager` singleton object. This method is a SwiftUI view function that you can use to load and render the player UI.

Example:

```swift
PlaybackSDKManager.shared.loadPlayer(
    entryID: entryId,
    authorizationToken: authorizationToken
) { error in
    // Handle player UI error as PlaybackAPIError
} 
```
**Error Handling:** For information on handling potential errors during playlist loading, see the [Error Handling](#error-handling) section.


## Loading a Playlist

To load a sequential list of videos into the player UI, use the `loadPlaylist` method of the `PlaybackSDKManager` singleton object. This method is a SwiftUI view function that you can use to load and render the player UI.
`entryIDs`: An array of Strings containing the unique identifiers of all the videos in the playlist.
`entryIDToPlay`: (Optional) Specifies the unique video identifier that will be played first in the playlist. If not provided, the first video in the `entryIDs` array will be played.

Example:

```swift
PlaybackSDKManager.shared.loadPlaylist(
    entryIDs: listEntryId,
    entryIDToPlay: "0_xxxxxxxx",
    authorizationToken: authorizationToken
) { errors in
    // Handle player UI playlist errors as [PlaybackAPIError]
} 
```
**Error Handling:** For information on handling potential errors during playlist loading, see the [Error Handling](#error-handling) section.


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

Then the same token should be passed into the `loadPlaylist` or `loadPlayer(entryID:, authorizationToken:)` method of `PlaybackSDKManager`.
For the free videos that user should be able to watch without logging in, starting the session is not required and `authorizationToken` can be set to an empty string.

> \[!NOTE]
> If the user is authenticated, has enough access level to watch a video, the session was started and the same token was passed to the player but the videos still throw a 401 error, it might be related to these requests having different user-agent headers.

## Playing Free Content

If you want to allow users to access free content or if you're implementing a guest mode, you can pass an empty string or `nil` value as the `authorizationToken` parameter when calling the `loadPlayer` or `loadPlaylist` function. This will bypass the need for authentication, enabling unrestricted access to the specified content.

## Configure user-agent

Sometimes a custom `user-agent` header is automatically set for the requests on iOS when creating a token and starting a session. `Alamofire` and other 3rd party networking frameworks can modify this header to include information about themselves. In such cases they should either be configured to not modify the header, or the custom header should be passed to the player as well.

Example:

```swift
PlaybackSDKManager.shared.initialize(
    apiKey: apiKey,
    baseURL: baseURL,
    userAgent: customUserAgent
) { result in
    // Handle player UI error as SDKError
}
```

By default the SDK uses system user agent, so if your app uses native URL Session, the `userAgent` parameter most likely can be omitted.

## Error Handling

The `PlaybackSDKManager` provides error handling through sealed classes `SDKError` and `PlaybackAPIError`. These classes represent various errors that can occur during SDK and API operations respectively.

- **`SDKError`** includes subclasses for initialization errors and missing license.
    - `initializationError` : General SDK initialization failure. Occurs with configuration issues or internal problems.
    - `missingLicense` : No valid license found. Occurs if no license key is provided or the key is invalid/expired.

- **`PlaybackAPIError`** This enum defines several cases, each representing a specific type of error that can occur during playback:
    - `initializationError` : An error during the initialization of the Playback API.
    - `invalidResponsePlaybackData` : The playback data received from the API was invalid.
    - `invalidPlaybackDataURL` : The URL providing the playback data was invalid.
    - `invalidPlayerInformationURL` : The URL providing player information was invalid.
    - `loadHLSStreamError` : An error occurred while loading the HLS stream.
    - `networkError(Error)` :  A network error occurred; it wraps another Error object for more detail.
    - `apiError(statusCode: Int, message: String, reason: PlaybackErrorReason)` : Represents API errors with specific details explained below
    - `unknown` : A generic error case for situations where the specific error type isn't known.
    
### ApiError Details
- `statusCode`: API error code (400, 401, 404, etc.)
- `message`: Error description.
- `reason`: Specific error classification from `PlaybackErrorReason`:
    - `headerError`: Invalid or missing request headers
    - `badRequestError`: Malformed request syntax
    - `siteNotFound`: Requested site resource doesn't exist
    - `configurationError`: Invalid backend configuration
    - `apiKeyError`: Invalid or missing API key
    - `mpPartnerError`: Partner-specific validation failure
    - `tokenError`: Invalid or expired authentication token
    - `tooManyDevices`: Device limit exceeded for account
    - `tooManyRequests`: Rate limit exceeded
    - `noEntitlement`: User lacks content access rights
    - `noSubscription`: No active subscription found
    - `noActiveSession`: Valid viewing session not found
    - `notAuthenticated`: General authentication failure
    - `noEntityExist`: Requested resource doesn't exist
    - `unknownError(String)`: Unclassified error with original error string

### Common ApiError StatusCode

 Code | Message               | Description                                                                   | Reasons
 ---- |-----------------------|-------------------------------------------------------------------------------|------------
 400  | Bad Request           | The request sent to the API was invalid or malformed.                         | headerError, badRequestError, siteNotFound, apiKeyError, mpPartnerError, configurationError
 401  | Unauthorized          | The user is not authenticated or authorized to access the requested resource. | tokenError, tooManyDevices, tooManyRequests, noEntitlement, noSubscription, notAuthenticated, mpPartnerError, configurationError, noActiveSession
 403  | Forbidden             | The user is not allowed to access the requested resource.                     |
 404  | Not Found             | The requested resource was not found on the server.                           | noEntityExist
 440  | Login Time-out        | Login session expired due to inactivity.                                      | noActiveSession
 500  | Internal Server Error | An unexpected error occurred on the server.                                   |

Handle errors based on these classes to provide appropriate feedback to users.

### Error Handling Example

```swift
PlaybackSDKManager.shared.loadPlayer(entryID: entryId,
                                     authorizationToken: authorizationToken,
                                     onError: { error in
    switch error {
    case .apiError(let statusCode, let message, let reason):
        switch reason {
        case .noEntitlement:
            errorMessage = "User lacks content access rights."
        case .notAuthenticated:
            errorMessage = "User is not authenticated."
        default:
            errorMessage = ""
        }
    case .networkError(let error):
        errorMessage = "Network issue: \(error.localizedDescription)"
    case .initializationError:
        errorMessage = "Initialization failed."
    default:
        errorMessage = "An unknown error occurred."
    }
})
```

## Video Player Plugin Manager

Additionally, the package includes a singleton object `VideoPlayerPluginManager` for managing video player plugins. This object allows you to register, remove, and retrieve the currently selected video player plugin.

For further details on how to use the `VideoPlayerPluginManager`, refer to the inline documentation provided in the code.

## Customizing Player Configuration

The Playback SDK provides methods to access and update the PlayerConfig of the Bitmovin player. This allows you to customize various aspects of the player's behavior and appearance dynamically.

To modify the player's configuration, you can use the following methods:
- **`updatePlayerConfig(_ newConfig: PlayerConfig)`** : Updates the current player configuration with a new PlayerConfig object.
- **`getPlayerConfig() -> PlayerConfig`** : Retrieves the current player configuration.
These methods enable you to adjust settings such as playback options, style configurations, and more, ensuring flexibility for your integration.

Example: 

```swift
import PlaybackSDK
import BitmovinPlayer

let bitmovinPlugin = BitmovinPlayerPlugin()
let myPlayerConfig = PlayerConfig()
// Disable Default Player UI
myPlayerConfig.styleConfig.isUiEnabled = false
bitmovinPlugin.updatePlayerConfig(myPlayerConfig)
```

## Bitmovin analytics

Currently SDK supports tracking analytics on Bitmovin service. In case you have a logged-in user and want to track Bitmovin analytics for the current session, you need to pass the user's ID in the `analyticsViewerId` parameter.

Example: 

```swift
let entryId = "..."
let authorizationToken = "..."
let analyticsViewerId = "user id or empty string"

/// ** Load player with the playback SDK **
PlaybackSDKManager.shared.loadPlayer(entryID: entryId,
                                    authorizationToken: authorizationToken,
                                    analyticsViewerId: analyticsViewerId,
                                    onError: {
error in
    // Handle the error as PlaybackAPIError        
})
```

## Playlist and Analytics

If you still need to track analytics with the playlist functionality, you can pass the user's ID in the `analyticsViewerId` parameter.

```swift
private let entryIDs = ["ENTRY_ID1", "ENTRY_ID_2", "ENTRY_ID_3"]
private let entryIDToPlay = "ENTRY_ID_2" // Optional parameter
private let authorizationToken = "JWT_TOKEN"
let analyticsViewerId = "user id or empty string"

var body: some View {
    VStack {
        // Load playlist with the playback SDK
        PlaybackSDKManager.shared.loadPlaylist(entryIDs: entryIDs, 
                                            entryIDToPlay: entryIDToPlay, 
                                            authorizationToken: authorizationToken,
                                            analyticsViewerId: analyticsViewerId) { 
            errors in
                // Handle Errors as [PlaybackAPIError]
                handlePlaybackError(errors)
        }
        .onDisappear {
            // Remove the player here
        }
        Spacer()
    }
    .padding()
}
```

## Resources

- **Demo app:** [GitHub Repository](https://github.com/StreamAMG/playback-demo-ios)
- **Stoplight API documentation:** [Documentation](https://streamamg.stoplight.io/docs/playback-sdk-ios/)
- **Tutorial (deprecated):** [Tutorial](https://streamamg.github.io/playback-sdk-ios/tutorials/table-of-contents/#resources)
