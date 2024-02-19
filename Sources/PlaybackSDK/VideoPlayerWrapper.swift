//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import BitmovinPlayer
import Combine
import SwiftUI

public struct VideoPlayerWrapper: View {
    private let entryId: String
    @StateObject private var viewModel: VideoPlayerViewModel
    private var amgAPIKey: String
    private var playerAPIKey: String
    
    private var playerViewConfig: BitmovinPlayerCore.PlayerViewConfig?
    private var sourceConfig: SourceConfig?
    @State private var hasFetchedVideoDetails = false
    
    public init(entryId: String, amgAPIKey: String, playerAPIKey: String) {
        self.entryId = entryId
        self.amgAPIKey = amgAPIKey
        self.playerAPIKey = playerAPIKey
        self._viewModel = StateObject(wrappedValue: VideoPlayerViewModel(playBackAPI: PlayBackAPIService(authorizationToken: "", apiKey: amgAPIKey)))
    }
    
    public var body: some View {
        Group {
            if !hasFetchedVideoDetails {
                ProgressView()
            } else {
                VideoPlayerViewAMG(apiKey: playerAPIKey, hlsURLString: viewModel.videoDetails?.media?.hls ?? "")
            }
            
            
        }
        .onAppear {
            fetchVideoDetails()
        }
    }
    
    private func fetchVideoDetails() {
        
        viewModel.fetchVideoDetails(forEntryId: entryId) {
            hasFetchedVideoDetails = true
        }
    }
}
