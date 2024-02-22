//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import BitmovinPlayer
import SwiftUI

public class BitmovinPlayerPlugin: VideoPlayerPlugin {
  
    private let playerConfig: PlayerConfig
    private var player: Player?
    
    // Required properties
    public let name: String
    public let version: String
    
    public init() {
        let playerConfig = PlayerConfig()
        
        playerConfig.playbackConfig.isAutoplayEnabled = true
        
        playerConfig.key = PlayBackSDKManager.shared.bitmovinLicense
        self.playerConfig = playerConfig
        self.name = "BitmovinPlayerPlugin"
        self.version = "1.0"
    }
    
    func getPlayer() -> Player? {
        return player
    }
    
    // MARK: VideoPlayerPlugin protocol implementation
    public func setup() {
        // Additional setup logic if needed, not required in this case
        // Might call here the configuration API
    }
    
    public func playerView(hlsURLString: String) -> AnyView {
        let videoPlayerView = BitMovinPlayerView(hlsURLString: hlsURLString, playerConfig: playerConfig)
       
        self.player = videoPlayerView.player
        
        return AnyView(videoPlayerView)
    }
    
    public func play() {
        player?.play()
    }
    
    public func pause() {
        player?.pause()
    }
    
    public func removePlayer() {
        player = nil // TODO: Remove properly
    }
    
    
    
}


