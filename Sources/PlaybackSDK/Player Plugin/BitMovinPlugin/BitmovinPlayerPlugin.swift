//
//  BitmovinPlayerPlugin.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import BitmovinPlayer
import SwiftUI
import Combine

public class BitmovinPlayerPlugin: VideoPlayerPlugin, ObservableObject {

    private let playerConfig: PlayerConfig
    private weak var player: Player? {
        didSet {
            if self.player != nil {
                listenPlayerEvents()
            }
        }
    }
    private var cancellables = Set<AnyCancellable>()

    // Required properties
    public let name: String
    public let version: String
    
    public let event: AnyPublisher<Any, Never>
    private let subject = PassthroughSubject<Any, Never>()
    
    public init() {
        let playerConfig = PlayerConfig()
        
        playerConfig.playbackConfig.isAutoplayEnabled = true
        playerConfig.playbackConfig.isBackgroundPlaybackEnabled = true
        
        playerConfig.key = PlaybackSDKManager.shared.bitmovinLicense
        self.playerConfig = playerConfig
        self.name = "BitmovinPlayerPlugin"
        self.version = "1.0.1" // TODO: Get the version from Bundle
        
        self.event = subject.eraseToAnyPublisher()
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
        // Check if player already loaded in order to avoid multiple pending player in memory
        if self.player == nil {
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

        return AnyView(
            BitmovinPlayerView(
                videoDetails: videoDetails,
                player: self.player!
            )
        )
    }
    
    public func listenPlayerEvents() {
        
        // Player Events
        player?.events
            .on(PlayerEvent.self)
            .sink { event in
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    self?.subject.send(event)
                }
            }
            .store(in: &cancellables)
        
        // Source Events
        player?.events
            .on(SourceEvent.self)
            .sink { event in
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    self?.subject.send(event)
                }
            }
            .store(in: &cancellables)
    }

    public func play() {
        player?.play()
    }

    public func pause() {
        player?.pause()
    }
    
    public func next() {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.isActive }) {
                if index < (sources.count ?? 0) - 1 {
                    let nextSource = sources[(index) + 1]
                    player?.playlist.seek(source: nextSource, time: 0)
                }
            }
        }
    }
    
    public func previous() {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.isActive }) {
                if index > 0 {
                    let prevSource = sources[(index) - 1]
                    player?.playlist.seek(source: prevSource, time: 0)
                }
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
    
    public func seek(to entryId: String) -> Bool {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.metadata?["entryId"] as? String == entryId }) {
                player?.playlist.seek(source: sources[index], time: 0)
                return true
            }
        }
        return false
    }
    
    public func activeEntryId() -> String? {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.isActive }) {
                if let entryId = sources[index].metadata?["entryId"] as? String {
                    return entryId
                }
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
