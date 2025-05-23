import SwiftUI
import PlaybackSDK
import Alamofire

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
        // Get the user-agent set by Alamofire
        let userAgent = AF.session.configuration.httpAdditionalHeaders?["User-Agent"]

        // Initialize the Playback SDK with the provided API key and custom user-agent
        PlaybackSDKManager.shared.initialize(apiKey: apiKey, userAgent: userAgent) { result in
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
                config.playbackConfig.skipBackForwardButton = true // Toggle Skip Forward and Backward buttons on Player UI
                bitmovinPlugin.setup(config: config)
                
                VideoPlayerPluginManager.shared.registerPlugin(bitmovinPlugin)

            case .failure(let error):
                // Print an error message and set initializationError flag upon initialization failure
                print("SDK initialization failed with error: \(error)")

            }
        }
    }
}
