//
//  BitmovinPlayerPlugin.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import BitmovinPlayer
import SwiftUI

public class BitmovinPlayerPlugin: VideoPlayerPlugin {

    private let playerConfig: PlayerConfig
    private var player: BitMovinPlayerView?
    
    // Required properties
    public let name: String
    public let version: String
    
    public init() {
        let playerConfig = PlayerConfig()
        
        playerConfig.playbackConfig.isAutoplayEnabled = true
        playerConfig.playbackConfig.isBackgroundPlaybackEnabled = true
        
        playerConfig.key = PlayBackSDKManager.shared.bitmovinLicense
        self.playerConfig = playerConfig
        self.name = "BitmovinPlayerPlugin"
        self.version = "1.0.1"
    }
    
    func getPlayer() -> Player? {
        return player?.player
    }
    
    // MARK: VideoPlayerPlugin protocol implementation
    public func setup(config: VideoPlayerConfig) {
        playerConfig.playbackConfig.isAutoplayEnabled = config.playbackConfig.autoplayEnabled
        playerConfig.playbackConfig.isBackgroundPlaybackEnabled = config.playbackConfig.backgroundPlaybackEnabled
    }
    
    public func playerView(hlsURLString: String, title: String = "") -> AnyView {
        let videoPlayerView = BitMovinPlayerView(hlsURLString: hlsURLString, playerConfig: playerConfig, title: title)
        
        self.player = videoPlayerView
        
        return AnyView(videoPlayerView)
    }
    
    public func play() {
        getPlayer()?.play()
    }
    
    public func pause() {
        getPlayer()?.pause()
    }
    
    public func removePlayer() {
        player?.player.unload()
        player?.player.destroy()
        player = nil
    }
}


#endif
