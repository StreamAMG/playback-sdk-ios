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
        
        playerConfig.key = PlayBackSDKManager.shared.bitmovinLicense
        self.playerConfig = playerConfig
        self.name = "BitmovinPlayerPlugin"
        self.version = "1.0.1"
    }
    
    // MARK: VideoPlayerPlugin protocol implementation
    public func setup(config: VideoPlayerConfig) {
        playerConfig.playbackConfig.isAutoplayEnabled = config.playbackConfig.autoplayEnabled
        playerConfig.playbackConfig.isBackgroundPlaybackEnabled = config.playbackConfig.backgroundPlaybackEnabled

        let uiConfig = BitmovinUserInterfaceConfig()
        uiConfig.hideFirstFrame = true
        playerConfig.styleConfig.userInterfaceConfig = uiConfig
    }
    
    private func createAnalyticsConfig(viewerId: String? = nil) -> AnalyticsPlayerConfig {
        guard let licenseKey = PlayBackSDKManager.shared.bitmovinLicense else {
            return .disabled
        }
        let defaultMetadata = DefaultMetadata(cdnProvider: "PlaybackSDK", customUserId: viewerId)
        let analytics: BitmovinPlayerAnalytics.AnalyticsPlayerConfig = licenseKey != nil
            ? .enabled(analyticsConfig: AnalyticsConfig(licenseKey: licenseKey), defaultMetadata: defaultMetadata)
            : .disabled
        return analytics
    }
    
    public func playerView(hlsURLString: String, title: String = "", viewerId: String? = nil) -> AnyView {

        // Create player based on player and analytics configurations
        let player = PlayerFactory.createPlayer(
            playerConfig: playerConfig,
            analytics: self.createAnalyticsConfig(viewerId: viewerId)
        )

        self.player = player

        return AnyView(
            BitMovinPlayerView(
                hlsURLString: hlsURLString,
                player: player,
                title: title
            )
        )
    }

    public func play() {
        player?.play()
    }

    public func pause() {
        player?.pause()
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
