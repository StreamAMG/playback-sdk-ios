//
//  BitMovinPlayerView.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import SwiftUI
import BitmovinPlayer
import MediaPlayer

public struct BitMovinPlayerView: View {
    internal let player: Player
    private let playerViewConfig: PlayerViewConfig
    private let hlsURLString: String
    
    private var sourceConfig: SourceConfig? {
        guard let hlsURL = URL(string: hlsURLString) else {
            return nil
        }
        let sConfig = SourceConfig(url: hlsURL, type: .hls)

        return sConfig
    }
    
    public init(hlsURLString: String, playerConfig: PlayerConfig, title: String) {
        
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
        
        // Setup remote control commands to be able to control playback from Control Center
        setupRemoteTransportControls()
        
        // Set playback metadata. Updates to the other metadata values are done in the specific listeners
        setupNowPlayingMetadata(key: MPMediaItemPropertyTitle, value: title)
        
        // Make sure that the correct audio session category is set to allow for background playback.
        handleAudioSessionCategorySetting()
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
       // .padding()
        .onAppear {
            if let sourceConfig = self.sourceConfig {
                player.load(sourceConfig: sourceConfig)
            }
        }
        .onDisappear {
            removeRemoteTransportControlsAndAudioSession()
        }
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget(handler: playTarget)
        commandCenter.playCommand.isEnabled = true

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget(handler: pauseTarget)
        commandCenter.pauseCommand.isEnabled = true
    }
    
    /// Remove RemoteCommandCenter and AudioSession
    func removeRemoteTransportControlsAndAudioSession() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = false
        commandCenter.playCommand.removeTarget(playTarget)
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.pauseCommand.removeTarget(pauseTarget)
        
        let sessionAV = AVAudioSession.sharedInstance()
        try? sessionAV.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    /// Play Target for RemoteCommandCenter
    func playTarget(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player as? Player else { return .commandFailed }

        player.play()
        if player.isPlaying {
            return .success
        }
        return .commandFailed
    }
    
    /// Pause Target for RemoteCommandCenter
    func pauseTarget(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player as? Player else { return .commandFailed }
        
        player.pause()
        if player.isPaused {
            return .success
        }
        return .commandFailed
    }
    
    func setupNowPlayingMetadata(key: String, value: Any) {
        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[key] = value
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    /* Set AVAudioSessionCategoryPlayback category on the audio session. This category indicates that audio playback
    is a central feature of your app. When you specify this category, your app’s audio continues with the Ring/Silent
    switch set to silent mode (iOS only). With this category, your app can also play background audio if you're
    using the Audio, AirPlay, and Picture in Picture background mode. To enable this mode, under the Capabilities
    tab in your XCode project, set the Background Modes switch to ON and select the “Audio, AirPlay, and Picture in
    Picture” option under the list of available modes. */
    func handleAudioSessionCategorySetting() {
        let audioSession = AVAudioSession.sharedInstance()

        // When AVAudioSessionCategoryPlayback is already active, we have nothing to do here
        guard audioSession.category.rawValue != AVAudioSession.Category.playback.rawValue else { return }

        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
}
#endif
