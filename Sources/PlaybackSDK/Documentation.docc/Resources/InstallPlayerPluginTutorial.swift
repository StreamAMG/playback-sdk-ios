import Foundation

PlayBackSDKManager.shared.initialize(apiKey: settingsManager.apiKey, baseURL: settingsManager.baseURL) { result in
    switch result {
    case .success(let license):
        print("SDK initialized with license: \(license)")
        
        // Add player plugin
        let bitmovinPlugin = BitmovinPlayerPlugin()
        VideoPlayerPluginManager.shared.registerPlugin(bitmovinPlugin)
        
    case .failure(let error):
        print("SDK initialization failed with error: \(error)")
    }
}
