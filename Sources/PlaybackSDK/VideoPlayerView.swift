//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import SwiftUI
import BitmovinPlayer

public struct VideoPlayerViewAMG: View {
    private let player: Player
    private let playerViewConfig: PlayerViewConfig
    private let apiKey: String
    private let hlsURLString: String
    
    private var sourceConfig: SourceConfig? {
        guard let hlsURL = URL(string: hlsURLString) else {
            return nil
        }
        return SourceConfig(url: hlsURL, type: .hls)
    }
    
    public init(apiKey: String, hlsURLString: String) {
        self.apiKey = apiKey
        self.hlsURLString = hlsURLString
        
        // Create player configuration
        let playerConfig = PlayerConfig()
        
        let uiConfig = BitmovinUserInterfaceConfig()
        uiConfig.hideFirstFrame = true
        playerConfig.styleConfig.userInterfaceConfig = uiConfig
        
        // Set your player license key on the player configuration
        playerConfig.key = apiKey
        
        // Create player based on player and analytics configurations
        self.player = PlayerFactory.createPlayer(
            playerConfig: playerConfig
            
        )
        
        // Create player view configuration
        self.playerViewConfig = PlayerViewConfig()
    }
    
    public var body: some View {
        ZStack {
            Color.black
            // Use the provided VideoPlayerView
            VideoPlayerView(player: player, playerViewConfig: playerViewConfig)
                .padding()
        }
        .onAppear {
            if let sourceConfig = self.sourceConfig {
                player.load(sourceConfig: sourceConfig)
            }
        }
    }
}
