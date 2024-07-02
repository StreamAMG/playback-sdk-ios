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
    
    /// The entry ID of the video to be played.
    private var entryId: String
    
    /// The title of the video to be played.
    private var mediaTitle: String?
    
    /// Optional authorization token if required to fetch the video details.
    private var authorizationToken: String?
    
    /// Observed object to manage the video player plugins.
    @ObservedObject private var pluginManager = VideoPlayerPluginManager.shared
    
    /// State variable to track whether video details have been fetched or not.
    @State private var hasFetchedVideoDetails = false
    
    /// State variable to store the HLS stream URL.
    @State private var videoURL: URL?
    
    /// Closure to handle errors during HLS stream loading.
    private var onError: ((PlayBackAPIError) -> Void)?
    /**
     Initializes the `PlaybackUIView` with the provided entry ID and authorization token.
     
     - Parameters:
     - entryId: The entry ID of the video to be played.
     - authorizationToken: Optional authorization token if required to fetch the video details.
     */
    internal init(entryId: String, authorizationToken: String?, mediaTitle: String?, onError: ((PlayBackAPIError) -> Void)?) {
        self.entryId = entryId
        self.authorizationToken = authorizationToken
        self.onError = onError
        self.mediaTitle = mediaTitle
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
                if let videoURL = videoURL {
                    if let plugin = pluginManager.selectedPlugin {
                        plugin.playerView(hlsURLString: videoURL.absoluteString, title: self.mediaTitle ?? "")
                    } else {
                        ErrorUIView(errorMessage: "No plugin selected")
                            .background(Color.white)
                    }
                } else {
                    ErrorUIView(errorMessage: "Invalid Video URL")
                        .background(Color.white)
                }
            }
        }
    }
    
    /**
     Loads the HLS stream for the provided entry ID and authorization token.
     
     This method asynchronously fetches the HLS stream URL using the `PlayBackSDKManager` and updates the `videoURL` state variable accordingly.
     */
    private func loadHLSStream() {
        PlayBackSDKManager.shared.loadHLSStream(forEntryId: entryId, andAuthorizationToken: authorizationToken) { result in
            switch result {
            case .success(let hlsURL):
                print("HLS URL: \(hlsURL)")
                self.videoURL = hlsURL
                self.hasFetchedVideoDetails = true
            case .failure(let error):
                // Trow error to the app
                onError?(error)
                print("Error loading HLS stream: \(error)")
            }
        }
    }
}


#endif
