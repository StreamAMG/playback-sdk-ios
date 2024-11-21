import SwiftUI
import PlaybackSDK

@main
struct PlaybackDemoApp: App {

    let sdkManager = PlaybackSDKManager()
    let apiKey = "API_KEY"
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }

    init() {
        // Initialize the Playback SDK with the provided API key and base URL
        PlaybackSDKManager.shared.initialize(apiKey: apiKey) { result in
            switch result {
            case .success(let license):
                // Obtained license upon successful initialization
                print("SDK initialized with license: \(license)")

                // Register the video player plugin
                let bitmovinPlugin = BitmovinPlayerPlugin()
                
                // Setting up player plugin
                var config = VideoPlayerConfig()
                config.playbackConfig.autoplayEnabled = true // Toggle autoplay
                config.playbackConfig.backgroundPlaybackEnabled = true // Toggle background playback
                bitmovinPlugin.setup(config: config)
                
                VideoPlayerPluginManager.shared.registerPlugin(bitmovinPlugin)

            case .failure(let error):
                // Print an error message and set initializationError flag upon initialization failure
                print("SDK initialization failed with error: \(error)")

            }
        }
    }
}

