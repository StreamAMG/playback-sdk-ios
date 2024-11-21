import SwiftUI
import PlaybackSDK

struct PlayerTestPlaylistControlsAndEventsView: View {
    
    @StateObject private var pluginManager = VideoPlayerPluginManager.shared
    private let entryIDs = ["ENTRY_ID1", "ENTRY_ID_2", "ENTRY_ID_3"]
    private let entryIDToPlay = "ENTRY_ID_2" // Optional parameter
    private let entryIdToSeek = "ENTRY_ID_TO_SEEK"
    private let authorizationToken = "JWT_TOKEN"
    
    var body: some View {
        VStack {
            // Load playlist with the playback SDK
            PlaybackSDKManager.shared.loadPlaylist(entryIDs: entryIDs, entryIDToPlay: entryIDToPlay, authorizationToken: authorizationToken) { errors in
                handlePlaybackError(errors)
            }
            .onReceive(pluginManager.selectedPlugin!.event) { event in
                if let event = event as? PlaylistTransitionEvent { // Playlist Event
                    if let from = event.from.metadata?["entryId"], let to = event.to.metadata?["entryId"] {
                        print("Playlist event changed from \(from) to \(to)")
                    }
                }
            }
            .onDisappear {
                // Remove the player here
            }
            
            Spacer()
            
            Button {
                // You can use the following playlist controls
                pluginManager.selectedPlugin?.first() // Play the first video
                pluginManager.selectedPlugin?.playPrevious() // Play the previous video
                pluginManager.selectedPlugin?.playNext() // Play the next video
                pluginManager.selectedPlugin?.last() // Play the last video
                pluginManager.selectedPlugin?.seek(to: entryIdToSeek) { success in // Seek to a specific video
                    if (!success) {
                        let errorMessage = "Unable to seek to \(entryIdToSeek)"
                    }
                }
                pluginManager.selectedPlugin?.activeEntryId() // Get the active video Id
            } label: {
                Image(systemName: "list.triangle")
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
