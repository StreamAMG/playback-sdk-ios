import SwiftUI
import PlaybackSDK

struct PlayerTestPlaylistView: View {
    
    private let entryIDs = ["ENTRY_ID1", "ENTRY_ID_2", "ENTRY_ID_3"]
    private let entryIDToPlay = "ENTRY_ID_2" // Optional parameter
    private let authorizationToken = "JWT_TOKEN"
    
    var body: some View {
        VStack {
            // Load playlist with the playback SDK
            PlaybackSDKManager.shared.loadPlaylist(entryIDs: entryIDs, entryIDToPlay: entryIDToPlay, authorizationToken: authorizationToken) { errors in
                handlePlaybackError(errors)
            }
            .onDisappear {
                // Remove the player here
            }
            Spacer()
        }
        .padding()
    }
    
    private func handlePlaybackErrors(_ errors: [PlaybackAPIError]) {
        
        for error in errors {
            switch error {
            case .apiError(let statusCode, let message, let reason):
                let message = "\(message) Status Code \(statusCode), Reason: \(reason)"
                print(message)
            default:
                print("Error code and errorrMessage not found: \(error.localizedDescription)")
            }
        }
    }
    
}
