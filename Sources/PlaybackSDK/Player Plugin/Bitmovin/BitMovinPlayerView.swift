//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import SwiftUI
import BitmovinPlayer

public struct BitMovinPlayerView: View {
    private let player: Player
    private let playerViewConfig: PlayerViewConfig
    private let hlsURLString: String
    
    private var sourceConfig: SourceConfig? {
        guard let hlsURL = URL(string: hlsURLString) else {
            return nil
        }
        return SourceConfig(url: hlsURL, type: .hls)
    }
    
    public init(hlsURLString: String, playerConfig: PlayerConfig) {
        
        self.hlsURLString = hlsURLString
        
        let uiConfig = BitmovinUserInterfaceConfig()
        uiConfig.hideFirstFrame = true
        playerConfig.styleConfig.userInterfaceConfig = uiConfig
        
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

            VideoPlayerView(
                player: player,
                playerViewConfig: playerViewConfig
            )
            .onReceive(player.events.on(PlayerEvent.self)) { (event: PlayerEvent) in
                dump(event, name: "[Player Event]", maxDepth: 1)
            }
            .onReceive(player.events.on(SourceEvent.self)) { (event: SourceEvent) in
                dump(event, name: "[Source Event]", maxDepth: 1)
            }
        }
        .padding()
        .onAppear {
            if let sourceConfig = self.sourceConfig {
                player.load(sourceConfig: sourceConfig)
            }
        }
    }
}
