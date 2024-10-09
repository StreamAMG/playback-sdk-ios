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
    private weak var player: Player?

    // Required properties
    public let name: String
    public let version: String
    
    public init() {
        let playerConfig = PlayerConfig()
        
        playerConfig.playbackConfig.isAutoplayEnabled = true
        playerConfig.playbackConfig.isBackgroundPlaybackEnabled = true
        
        playerConfig.key = PlaybackSDKManager.shared.bitmovinLicense
        self.playerConfig = playerConfig
        self.name = "BitmovinPlayerPlugin"
        self.version = "1.0.1" // TODO: Get the version from Bundle
    }
    
    // MARK: VideoPlayerPlugin protocol implementation
    public func setup(config: VideoPlayerConfig) {
        playerConfig.playbackConfig.isAutoplayEnabled = config.playbackConfig.autoplayEnabled
        playerConfig.playbackConfig.isBackgroundPlaybackEnabled = config.playbackConfig.backgroundPlaybackEnabled

        let uiConfig = BitmovinUserInterfaceConfig()
        uiConfig.hideFirstFrame = true
        playerConfig.styleConfig.userInterfaceConfig = uiConfig
    }
    
    public func playerView(videoDetails: [PlaybackResponseModel]) -> AnyView {

        // Create player based on player and analytics configurations
        let player = PlayerFactory.createPlayer(
            playerConfig: playerConfig
        )

        self.player = player

        return AnyView(
            BitmovinPlayerView(
                videoDetails: videoDetails,
                player: player
            )
        )
    }

    public func play() {
        player?.play()
    }

    public func pause() {
        player?.pause()
    }
    
    public func next() {
        if let index = player?.playlist.sources.firstIndex(where: { $0.isActive }) {
            if index < (player?.playlist.sources.count ?? 0) - 1, let nextSource = player?.playlist.sources[(index) + 1] {
                player?.playlist.seek(source: nextSource, time: 0)
            }
        }
    }
    
    public func previous() {
        if let index = player?.playlist.sources.firstIndex(where: { $0.isActive }) {
            if index > 0, let prevSource = player?.playlist.sources[(index) - 1] {
                player?.playlist.seek(source: prevSource, time: 0)
            }
        }
    }
    
    public func last() {
        if let lastSource = player?.playlist.sources.last {
            player?.playlist.seek(source: lastSource, time: 0)
        }
    }
    
    public func first() {
        if let firstSource = player?.playlist.sources.first {
            player?.playlist.seek(source: firstSource, time: 0)
        }
    }
    
    public func seek(to entryId: String) {
        if let index = player?.playlist.sources.firstIndex(where: { $0.metadata?["entryId"] as? String == entryId }) {
            if let source = player?.playlist.sources[index] {
                player?.playlist.seek(source: source, time: 0)
                player?.play()
            }
        }
    }
    
    public func activeEntryId() -> String? {
        if let index = player?.playlist.sources.firstIndex(where: { $0.isActive }) {
            if let entryId = player?.playlist.sources[index].metadata?["entryId"] as? String {
                return entryId
            }
        }
        return nil
    }

    public func unload() {
        player?.unload()
    }

    public func removePlayer() {
        player?.unload()
        player?.destroy()
    }
}


#endif
