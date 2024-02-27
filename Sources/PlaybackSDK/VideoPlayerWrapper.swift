//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Combine
import SwiftUI

/**
 `VideoPlayerWrapper` is a SwiftUI view that facilitates playing HLS streams. It utilizes an external plugin to render the video player.
 
 ## Overview:
 
 - The `VideoPlayerWrapper` struct serves as a container for displaying HLS streams within a SwiftUI environment.
 - It asynchronously fetches the HLS stream URL using the provided `entryId` and optional `authorizationToken`.
 - Once the HLS stream URL is fetched, it renders the video player using the selected plugin from `VideoPlayerPluginManager`.
 
 ## Usage:
 
 - Initialize an instance of `VideoPlayerWrapper` with the required parameters: `entryId` and optional `authorizationToken`.
 
 ## Important Points:
 
 - Ensure that the provided `entryId` corresponds to a valid video entry.
 - If an `authorizationToken` is required for fetching video details, provide it; otherwise, pass `nil`.
 - `VideoPlayerPluginManager` manages the plugins for the video player.
 
 */

internal struct VideoPlayerWrapper: View {
    
    /// The entry ID of the video to be played.
    private var entryId: String
    
    /// Optional authorization token if required to fetch the video details.
    private var authorizationToken: String?
    
    /// Observed object to manage the video player plugins.
    @ObservedObject private var pluginManager = VideoPlayerPluginManager.shared
    
    /// State variable to track whether video details have been fetched or not.
    @State private var hasFetchedVideoDetails = false
    
    /// State variable to store the HLS stream URL.
    @State private var videoURL: URL?
    
    /**
     Initializes the `VideoPlayerWrapper` with the provided entry ID and authorization token.
     
     - Parameters:
     - entryId: The entry ID of the video to be played.
     - authorizationToken: Optional authorization token if required to fetch the video details.
     */
    internal init(entryId: String, authorizationToken: String?) {
        self.entryId = entryId
        self.authorizationToken = authorizationToken
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
                        plugin.playerView(hlsURLString: videoURL.absoluteString)
                    } else {
                        Text("No plugin selected")
                    }
                } else {
                    Text("Invalid Video URL")
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
                print("Error loading HLS stream: \(error)")
            }
        }
    }
}
