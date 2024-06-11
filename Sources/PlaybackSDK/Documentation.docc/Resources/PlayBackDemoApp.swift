import SwiftUI
import PlaybackSDK

@main
struct PlayBackDemoApp: App {
    
    let sdkManager = PlayBackSDKManager()
    let apiKey = "API_KEY"
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
    
    init() {
        // Initialize the Playback SDK with the provided API key and base URL
        PlayBackSDKManager.shared.initialize(apiKey: apiKey) { result in
            switch result {
            case .success(let license):
                // Obtained license upon successful initialization
                print("SDK initialized with license: \(license)")
                
                // Register the video player plugin
                let bitmovinPlugin = BitmovinPlayerPlugin()
                VideoPlayerPluginManager.shared.registerPlugin(bitmovinPlugin)
                
            case .failure(let error):
                // Print an error message and set initializationError flag upon initialization failure
                print("SDK initialization failed with error: \(error)")
                
            }
        }
    }
}
