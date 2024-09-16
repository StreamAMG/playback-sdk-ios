//
//  BitmovinPlayerPlugin.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import BitmovinPlayer
import SwiftUI
import MuxCore
import MUXSDKBitmovin

public class BitmovinPlayerPlugin: VideoPlayerPlugin {

    private let playerConfig: PlayerConfig
    private weak var player: Player?

    // Required properties
    public let name: String
    public let version: String
    
    let environmentKey = "5lm0oqcj9ghkpnddlnfvkfmgk"
    
    public init() {
        let playerConfig = PlayerConfig()
        
        playerConfig.playbackConfig.isAutoplayEnabled = true
        playerConfig.playbackConfig.isBackgroundPlaybackEnabled = true
        
        playerConfig.key = PlayBackSDKManager.shared.bitmovinLicense
        self.playerConfig = playerConfig
        self.name = "BitmovinPlayerPlugin"
        self.version = "1.0.1"
    }
    
    private func setupMux() {
        let playerData = MUXSDKCustomerPlayerData(environmentKey: self.environmentKey)
        playerData?.playerName = self.name
        
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Title Video Bitmovin"
        videoData.videoId = "sintel"
        
        let viewData = MUXSDKCustomerViewData()
        viewData.viewSessionId = "my session id"
        
        let customData = MUXSDKCustomData()
        customData.customData1 = "Bitmovin test"
        customData.customData2 = "Custom Data 2"
        
        let viewerData = MUXSDKCustomerViewerData()
        viewerData.viewerApplicationName = "MUX Bitmovin DemoApp"
        
        let customerData = MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: viewData,
            customData: customData,
            viewerData: viewerData
        )
        
        guard let playerView = self.player, let data = customerData else {
            return
        }
        
        if let player = self.player {
            let playerview = BitmovinPlayerCore.PlayerView(player: player, frame: CGRectZero)
            MUXSDKStats.monitorPlayer(
                player: playerview,
                playerName: self.name,
                customerData: data
            )
        }
    }
    
    // MARK: VideoPlayerPlugin protocol implementation
    public func setup(config: VideoPlayerConfig) {
        playerConfig.playbackConfig.isAutoplayEnabled = config.playbackConfig.autoplayEnabled
        playerConfig.playbackConfig.isBackgroundPlaybackEnabled = config.playbackConfig.backgroundPlaybackEnabled

        let uiConfig = BitmovinUserInterfaceConfig()
        uiConfig.hideFirstFrame = true
        playerConfig.styleConfig.userInterfaceConfig = uiConfig
    }
    
    public func playerView(hlsURLString: String, title: String = "") -> AnyView {

        // Create player based on player and analytics configurations
        let player = PlayerFactory.createPlayer(
            playerConfig: playerConfig
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
