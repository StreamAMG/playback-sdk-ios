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
    
    private var entryId: String
    private var authorizationToken: String?
    
    @ObservedObject private var pluginManager = VideoPlayerPluginManager.shared 
    
    
    @State private var hasFetchedVideoDetails = false
    @State private var videoURL: URL?
    
    public init(entryId: String, authorizationToken: String?) {
        self.entryId = entryId
        self.authorizationToken = authorizationToken
    }
    
    public var body: some View {
        VStack {
            Spacer()
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
            Spacer()
        }
    }
    
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
