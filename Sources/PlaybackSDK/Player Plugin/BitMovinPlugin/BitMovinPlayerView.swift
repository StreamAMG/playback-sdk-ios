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
    // These targets are used by the MPRemoteCommandCenter,
    // to remove the command event handlers from memory.
    @State private var playEventTarget: Any?
    @State private var pauseEventTarget: Any?

    private let player: Player
    private let playerViewConfig = PlayerViewConfig()
    private let hlsURLString: String

    private var sourceConfig: SourceConfig? {
        guard let hlsURL = URL(string: hlsURLString) else {
            return nil
        }
        let sConfig = SourceConfig(url: hlsURL, type: .hls)

        return sConfig
    }

    /// Initializes the view with the player passed from outside.
    ///
    /// This version of the initializer does not modify the `player`'s configuration, so any additional configuration steps 
    /// like setting `userInterfaceConfig` should be performed externally.
    ///
    /// - parameter hlsURLString: Full URL of the HLS video stream that will be loaded by the player as the video source
    /// - parameter player: Instance of the player that was created and configured outside of this view.
    /// - parameter title: Video source title that will be set in playback metadata for the "now playing" source
    public init(hlsURLString: String, player: Player, title: String) {

        self.hlsURLString = hlsURLString

        self.player = player

        setup(title: title)
    }

    /// Initializes the view with an instance of player created inside of it, upon initialization.
    ///
    /// In this version of the initializer, a `userInterfaceConfig` is being added to the `playerConfig`'s style configuration.
    ///
    /// - Note: If the player config had `userInterfaceConfig` already modified before passing into this `init`,
    /// those changes will take no effect sicne they will get overwritten here.
    ///
    /// - parameter hlsURLString: Full URL of the HLS video stream that will be loaded by the player as the video source
    /// - parameter playerConfig: Configuration that will be passed into the player upon creation, with an additional update in this initializer.
    /// - parameter title: Video source title that will be set in playback metadata for the "now playing" source
    public init(hlsURLString: String, playerConfig: PlayerConfig, title: String) {
        
        self.hlsURLString = hlsURLString
        
        let uiConfig = BitmovinUserInterfaceConfig()
        uiConfig.hideFirstFrame = true
        playerConfig.styleConfig.userInterfaceConfig = uiConfig
        
        // Create player based on player and analytics configurations
        self.player = PlayerFactory.createPlayer(
            playerConfig: playerConfig
        )

        setup(title: title)
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
        playEventTarget = commandCenter.playCommand.addTarget(handler: handleRemotePlayEvent)
        commandCenter.playCommand.isEnabled = true

        // Add handler for Pause Command
        pauseEventTarget = commandCenter.pauseCommand.addTarget(handler: handleRemotePauseEvent)
        commandCenter.pauseCommand.isEnabled = true
    }

    /// Remove RemoteCommandCenter and AudioSession
    func removeRemoteTransportControlsAndAudioSession() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = false
        commandCenter.playCommand.removeTarget(playEventTarget)
        playEventTarget = nil

        commandCenter.pauseCommand.isEnabled = false
        commandCenter.pauseCommand.removeTarget(pauseEventTarget)
        pauseEventTarget = nil

        let sessionAV = AVAudioSession.sharedInstance()
        try? sessionAV.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    /// Play event handler for RemoteCommandCenter
    func handleRemotePlayEvent(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.play()
        return player.isPlaying ? .success : .commandFailed
    }
    
    /// Pause event handler for RemoteCommandCenter
    func handleRemotePauseEvent(_: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        player.pause()
        return player.isPaused ? .success : .commandFailed
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

    private func setup(title: String) {

        // Setup remote control commands to be able to control playback from Control Center
        setupRemoteTransportControls()

        // Set playback metadata. Updates to the other metadata values are done in the specific listeners
        setupNowPlayingMetadata(key: MPMediaItemPropertyTitle, value: title)

        // Make sure that the correct audio session category is set to allow for background playback.
        handleAudioSessionCategorySetting()
    }
}
#endif
