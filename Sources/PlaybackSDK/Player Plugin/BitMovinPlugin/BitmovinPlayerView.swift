//
//  BitmovinPlayerView.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import SwiftUI
import BitmovinPlayer
import MediaPlayer
import Combine

public struct BitmovinPlayerView: View {
    // These targets are used by the MPRemoteCommandCenter,
    // to remove the command event handlers from memory.
    @State private var playEventTarget: Any?
    @State private var pauseEventTarget: Any?

    private let player: Player
    private var playerViewConfig = PlayerViewConfig()
    private var sources: [Source] = []
    private var entryIDToPlay: String?
    private var authorizationToken: String?
    
    private var playlistConfig: PlaylistConfig? {
        if sources.isEmpty || sources.count == 1 {
            return nil
        }
        let playlistOptions = PlaylistOptions(preloadAllSources: false)
        return PlaylistConfig(sources: sources, options: playlistOptions)
    }
    
    private var sourceConfig: SourceConfig? {
        if sources.isEmpty || sources.count > 1 {
            return nil
        }
        let sConfig = sources.first!.sourceConfig
        return sConfig
    }

    /**
    Initializes the view with the player passed from outside.
     
    This version of the initializer does not modify the `player`'s configuration, so any additional configuration steps
    like setting `userInterfaceConfig` should be performed externally.
     
     - Parameters:
        - videoDetails: Full videos details containing title, description, thumbnail, duration as well as URL of the HLS video stream that will be loaded by the player as the video source
        - entryIDToPlay: (Optional) The first video Id to be played. If not provided, the first video in the entryIDs array will be played.
        - authorizationToken: (Optional) The token used for authorization to access the video content.
        - player: Instance of the player that was created and configured outside of this view.
    */
    public init(videoDetails: [PlaybackVideoDetails], entryIDToPlay: String?, authorizationToken: String?, player: Player) {

        self.player = player
        self.authorizationToken = authorizationToken
        self.entryIDToPlay = entryIDToPlay
        
        playerViewConfig = PlayerViewConfig()
        
        sources = createPlaylist(from: videoDetails)
        
        setupRemoteCommandCenter(title: videoDetails.first?.title ?? "")
    }

    /**
    Initializes the view with an instance of player created inside of it, upon initialization.
    
    In this version of the initializer, a `userInterfaceConfig` is being added to the `playerConfig`'s style configuration.
    
    - Note: If the player config had `userInterfaceConfig` already modified before passing into this `init`,
    those changes will take no effect since they will get overwritten here.
    
    - Parameters:
     - videoDetails: Full videos details containing title, description, thumbnail, duration as well as URL of the HLS video stream that will be loaded by the player as the video source
     - entryIDToPlay: (Optional) The first video Id to be played. If not provided, the first video in the entryIDs array will be played.
     - authorizationToken: (Optional) The token used for authorization to access the video content.
     - playerConfig: Configuration that will be passed into the player upon creation, with an additional update in this initializer.
    */
    public init(videoDetails: [PlaybackVideoDetails], entryIDToPlay: String?, authorizationToken: String?, playerConfig: PlayerConfig) {
        
        let uiConfig = BitmovinUserInterfaceConfig()
        uiConfig.hideFirstFrame = true
        playerConfig.styleConfig.userInterfaceConfig = uiConfig
        
        // Create player based on player and analytics configurations
        self.player = PlayerFactory.createPlayer(
            playerConfig: playerConfig
        )
        self.authorizationToken = authorizationToken
        self.entryIDToPlay = entryIDToPlay
        
        sources = createPlaylist(from: videoDetails)
        
        setupRemoteCommandCenter(title: videoDetails.first?.title ?? "")
    }

    public var body: some View {
        ZStack {
            Color.black

            VideoPlayerView(
                player: player,
                playerViewConfig: playerViewConfig
            )
            // Disable player touch in case video or playlist not been loaded
            .allowsHitTesting(self.sourceConfig != nil || self.playlistConfig != nil)
        }
        .onAppear {
            if let playlistConfig = self.playlistConfig {
                // Multiple videos with playlist available so load player with playlistConfig
                player.load(playlistConfig: playlistConfig)
                if let entryIDToPlay = self.entryIDToPlay {
                    if let index = player.playlist.sources.firstIndex(where: { $0.sourceConfig.metadata["entryId"] as? String == entryIDToPlay }) {
                        player.playlist.seek(source: sources[index], time: .zero)
                        player.seek(time: .zero) // Player seek to avoid black screen
                    }
                }
            } else if let sourceConfig = self.sourceConfig {
                // Single video available so load player with sourceConfig
                player.load(sourceConfig: sourceConfig)
            }
        }
        .onDisappear {
            removeRemoteTransportControlsAndAudioSession()
        }
    }
    
    func createPlaylist(from videoDetails: [PlaybackVideoDetails]) -> [Source] {
        var sources: [Source] = []
        for details in videoDetails {
            
            if let videoSource = PlaybackSDKManager.shared.createSource(from: details, authorizationToken: self.authorizationToken) {
                sources.append(videoSource)
            }
        }
        
        return sources
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

    private func setupRemoteCommandCenter(title: String) {

        // Setup remote control commands to be able to control playback from Control Center
        setupRemoteTransportControls()

        // Set playback metadata. Updates to the other metadata values are done in the specific listeners
        setupNowPlayingMetadata(key: MPMediaItemPropertyTitle, value: title)

        // Make sure that the correct audio session category is set to allow for background playback.
        handleAudioSessionCategorySetting()
    }
}
#endif
