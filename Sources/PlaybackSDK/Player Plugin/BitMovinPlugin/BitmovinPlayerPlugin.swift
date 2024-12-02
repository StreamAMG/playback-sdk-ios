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
                listenToPlayerEvents()
            }
        }
    }
    private var cancellables = Set<AnyCancellable>()
    private var authorizationToken: String? = nil
    private var entryIDToPlay: String?

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
        self.version = "1.3.0" // TODO: Get the version from Bundle
        
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
    
    public func playerView(videoDetails: [PlaybackVideoDetails], entryIDToPlay: String?, authorizationToken: String?) -> AnyView {
        self.authorizationToken = authorizationToken
        self.entryIDToPlay = entryIDToPlay
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
                    entryIDToPlay: entryIDToPlay,
                    authorizationToken: self.authorizationToken,
                    player: player
                )
            )
        }

        return AnyView(
            BitmovinPlayerView(
                videoDetails: videoDetails,
                entryIDToPlay: entryIDToPlay,
                authorizationToken: self.authorizationToken,
                player: self.player!
            )
        )
    }
    
    private func listenToPlayerEvents() {
        
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
    
    public func playNext() {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.isActive }) {
                let nextIndex = index + 1
                if nextIndex < sources.count {
                    let nextSource = sources[nextIndex]
                    seekSource(to: nextSource)
                }
            }
        }
    }
    
    public func playPrevious() {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.isActive }) {
                if index > 0 {
                    let prevSource = sources[(index) - 1]
                    seekSource(to: prevSource)
                }
            }
        }
    }
    
    public func playLast() {
        if let lastSource = player?.playlist.sources.last {
            seekSource(to: lastSource)
        }
    }
    
    public func playFirst() {
        if let firstSource = player?.playlist.sources.first {
            seekSource(to: firstSource)
        }
    }
    
    public func seek(_ entryId: String, completion: @escaping (Bool) -> Void) {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.sourceConfig.metadata["entryId"] as? String == entryId }) {
                seekSource(to: sources[index]) { success in
                    completion(success)
                }
            } else {
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    private func seekSource(to source: Source, completion: ( (Bool) -> (Void))? = nil) {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.sourceConfig.metadata["entryId"] as? String == source.sourceConfig.metadata["entryId"] as? String }) {
                updateSource(for: sources[index]) { updatedSource in
                    if let updatedSource = updatedSource {
                        self.player?.playlist.remove(sourceAt: index)
                        self.player?.playlist.add(source: updatedSource, at: index)
                        
                        // Due to a Bitmovin playlist issue, if the current video is live, we need to reload the playlist in order to change the media
                        let refreshPlaylist = self.player?.isLive ?? false
                        
                        if refreshPlaylist {
                            if let sources = self.player?.playlist.sources {
                                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                                    self?.player?.pause()
                                    self?.player?.unload()
                                    
                                    let playlistOptions = PlaylistOptions(preloadAllSources: false)
                                    let pConfig = PlaylistConfig(sources: sources, options: playlistOptions)
                                    
                                    self?.player?.load(playlistConfig: pConfig)
                                    self?.player?.playlist.seek(source: updatedSource, time: .zero)
                                    self?.player?.seek(time: .zero) // Player seek to avoid black screen
                                }
                            }
                        } else {
                            self.player?.playlist.seek(source: updatedSource, time: .zero)
                        }
                        
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                }
            }
        }
    }
    
    private func updateSource(for source: Source, completion: @escaping (Source?) -> Void) {
        
        let entryId = source.sourceConfig.metadata["entryId"] as? String
        let authorizationToken = source.sourceConfig.metadata["authorizationToken"] as? String
        
        if let entryId = entryId {
            PlaybackSDKManager.shared.loadHLSStream(forEntryId: entryId, andAuthorizationToken: authorizationToken) { result in
                switch result {
                case .success(let response):
                    if let videoDetails = response.toVideoDetails() {
                        let newSource = PlaybackSDKManager.shared.createSource(from: videoDetails, authorizationToken: authorizationToken)
                        completion(newSource)
                    } else {
                        completion(nil)
                    }
                case .failure:
                    break
                    completion(nil)
                }
            }
        }
    }
    
    public func activeEntryId() -> String? {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.isActive }) {
                if let entryId = sources[index].sourceConfig.metadata["entryId"] as? String {
                    return entryId
                }
            }
        }

        return nil
    }
    
    private func activeSource() -> Source? {
        if let sources = player?.playlist.sources {
            if let index = sources.firstIndex(where: { $0.isActive }) {
                return sources[index]
            }
        }
        
        return nil
    }
    
    private func isLiveSource(source: Source) -> Bool {
        if source.sourceConfig.type == .hls && source.sourceConfig.url.absoluteString.contains("/live/") {
            return true
        } else if source.sourceConfig.type == .dash {
            return true
        }
        
        return false
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
