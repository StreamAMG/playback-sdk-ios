import PlaybackSDK

PlaybackSDKManager.shared.initialize(apiKey: "YOUR_API_KEY") { result in
    switch result {
    case .success:
        print("Playback SDK initialized successfully.")
    case .failure(let error):
        print("Error initializing Playback SDK: \(error)")
    }
}
