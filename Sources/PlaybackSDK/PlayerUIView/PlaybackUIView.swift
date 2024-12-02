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
    private var entryIds: [String]
    
    /// The entryID to play at the beginning
    private var entryIDToPlay: String?
    
    /// Optional authorization token if required to fetch the video details.
    private var authorizationToken: String?
    
    /// Optional user ID to be tracked in analytics
    private var analyticsViewerId: String?
    
    /// Observed object to manage the video player plugins.
    @ObservedObject private var pluginManager = VideoPlayerPluginManager.shared
    
    /// State variable to track whether video details have been fetched or not.
    @State private var hasFetchedVideoDetails = false
    
    /// The fetched video details of the entryIDs
    @State private var videoDetails: [PlaybackVideoDetails]?
    /// Array of errors for fetching playlist details
    @State private var playlistErrors: [PlaybackAPIError]?
    /// Error of failed API call for loading video details
    @State private var failureError: PlaybackAPIError?
    
    /// Closure to handle errors during a single HLS stream loading.
    private var onError: ((PlaybackAPIError) -> Void)?
    /// Closure to handle multiple errors during Playlist stream loading.
    private var onErrors: (([PlaybackAPIError]) -> Void)?
    
    /**
     Initializes the `PlaybackUIView` with the provided list of entry ID and authorization token.
     
     - Parameters:
        - entryIds: A list of entry ID of the video to be played.
        - entryIDToPlay: (Optional) The first video Id to be played. If not provided, the first video in the entryIDs array will be played.
        - authorizationToken: (Optional) Authorization token if required to fetch the video details.
        - analyticsViewerId: User identifier to be tracked in analytics
        - onErrors: Return a list of potential playback errors that may occur during the loading process for single entryId.
     */

    internal init(entryIds: [String], entryIDToPlay: String?, authorizationToken: String?, analyticsViewerId: String?, onErrors: (([PlaybackAPIError]) -> Void)?) {
        self.entryIds = entryIds
        self.entryIDToPlay = entryIDToPlay ?? entryIds.first
        self.authorizationToken = authorizationToken
        self.analyticsViewerId = analyticsViewerId
        self.onErrors = onErrors
    }
    
    /**
     Initializes the `PlaybackUIView` with the provided list of entry ID and authorization token.
     
     - Parameters:
        - entryId: An entry ID of the video to be played.
        - authorizationToken: Optional authorization token if required to fetch the video details.
        - analyticsViewerId: User identifier to be tracked in analytics
        - onError: Return potential playback errors that may occur during the loading process.
     */
    internal init(entryId: String, authorizationToken: String?, analyticsViewerId: String?, onError: ((PlaybackAPIError) -> Void)?) {
        self.entryIds = [entryId]
        self.authorizationToken = authorizationToken
        self.analyticsViewerId = analyticsViewerId
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
                        plugin.playerView(videoDetails: videoDetails, entryIDToPlay: entryIDToPlay, authorizationToken: authorizationToken, analyticsViewerId: self.analyticsViewerId)
                    } else {
                        ErrorUIView(errorMessage: "No plugin selected")
                            .background(Color.white)
                    }
                } else if let locDesc = self.failureError?.localizedDescription {
                    ErrorUIView(errorMessage: locDesc)
                        .background(Color.white)
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
        
        PlaybackSDKManager.shared.loadAllHLSStream(forEntryIds: entryIds, andAuthorizationToken: authorizationToken) { result in
            switch result {
            case .success(let videoDetails):
                DispatchQueue.main.async {
                    self.videoDetails = []
                    for details in videoDetails.0 {
                        if let videoDetails = details.toVideoDetails() {
                            self.videoDetails?.append(videoDetails)
                        }
                    }
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
                self.failureError = error
                self.hasFetchedVideoDetails = true
                print("Error loading videos details: \(error)")
            }
        }
    }
}


#endif
