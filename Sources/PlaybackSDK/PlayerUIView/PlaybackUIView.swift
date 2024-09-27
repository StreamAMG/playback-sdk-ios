//
//  PlaybackUIView.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import Combine
import SwiftUI

/**
 `PlaybackUIView` is a SwiftUI view that facilitates playing HLS streams. It utilizes an external plugin to render the video player.
 */
internal struct PlaybackUIView: View {
    
    /// The entry ID or a list of the videos to be played.
    private var entryId: [String]
    
    /// Optional authorization token if required to fetch the video details.
    private var authorizationToken: String?
    
    /// Observed object to manage the video player plugins.
    @ObservedObject private var pluginManager = VideoPlayerPluginManager.shared
    
    /// State variable to track whether video details have been fetched or not.
    @State private var hasFetchedVideoDetails = false
    
    /// The fetched video details of the entryIDs
    @State private var videoDetails: [PlaybackResponseModel]?
    @State private var playlistErrors: [PlaybackAPIError]?
    
    /// Closure to handle errors during a single HLS stream loading.
    private var onError: ((PlaybackAPIError) -> Void)?
    /// Closure to handle multiple errors during Playlist stream loading.
    private var onErrors: (([PlaybackAPIError]) -> Void)?
    
    /**
     Initializes the `PlaybackUIView` with the provided list of entry ID and authorization token.
     
     - Parameters:
     - entryId: A list of entry ID of the video to be played.
     - authorizationToken: Optional authorization token if required to fetch the video details.
     */
    internal init(entryId: [String], authorizationToken: String?, onErrors: (([PlaybackAPIError]) -> Void)?) {
        self.entryId = entryId
        self.authorizationToken = authorizationToken
        self.onErrors = onErrors
    }
    
    /**
     Initializes the `PlaybackUIView` with the provided list of entry ID and authorization token.
     
     - Parameters:
     - entryId: A list of entry ID of the video to be played.
     - authorizationToken: Optional authorization token if required to fetch the video details.
     */
    internal init(entryId: [String], authorizationToken: String?, onError: ((PlaybackAPIError) -> Void)?) {
        self.entryId = entryId
        self.authorizationToken = authorizationToken
        self.onError = onError
    }
    
    /// The body of the view.
    internal var body: some View {
        VStack {
            if !hasFetchedVideoDetails {
                ProgressView()
                    .onAppear {
                        loadHLSStream()
                    }
            } else {
                if let videoDetails = videoDetails {
                    if let plugin = pluginManager.selectedPlugin {
                        plugin.playerView(videoDetails: videoDetails)
                    } else {
                        ErrorUIView(errorMessage: "No plugin selected")
                            .background(Color.white)
                    }
                } else {
                    ErrorUIView(errorMessage: "Invalid Video Details")
                        .background(Color.white)
                }
            }
        }
    }
    
    /**
     Loads the HLS stream for the provided entry ID and authorization token.
     
     This method asynchronously fetches the HLS stream URL using the `PlaybackSDKManager` and updates the `videoURL` state variable accordingly.
     */
    private func loadHLSStream() {
        
        //TO-DO Fetch all HLS urls from the entryID array
        PlaybackSDKManager.shared.loadAllHLSStream(forEntryIds: entryId, andAuthorizationToken: authorizationToken) { result in
            switch result {
            case .success(let videoDetails):
                DispatchQueue.main.async {
                    self.videoDetails = videoDetails.0
                    self.playlistErrors = videoDetails.1
                    self.hasFetchedVideoDetails = true
                    if (!(self.playlistErrors?.isEmpty ?? false)) {
                        onError?(self.playlistErrors?.last ?? .unknown)
                        onErrors?(self.playlistErrors ?? [])
                    }
                }
            case .failure(let error):
                // Trow error to the app
                onError?(error)
                onErrors?([error])
                print("Error loading videos details: \(error)")
            }
        }
    }
}


#endif
