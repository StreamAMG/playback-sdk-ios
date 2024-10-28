//
//  VideoPlayerPlugin.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import AVFoundation
import SwiftUI
import Combine

// Protocol for defining a video player plugin
public protocol VideoPlayerPlugin: AnyObject {
    
    var name: String { get }
    var version: String { get }
    var event: AnyPublisher<Any, Never> { get }
    
    func setup(config: VideoPlayerConfig)
    
    // TODO: add event
    /// func handleEvent(event: BitmovinPlayerCore.PlayerEvent)
    
    func playerView(videoDetails: [PlaybackResponseModel]) -> AnyView
    
    func play()
    
    func pause()
    
    func playNext()
    
    func playPrevious()
    
    func last()
    
    func first()
    
    func seek(to entryId: String) -> Bool
    
    func activeEntryId() -> String?
    
    func removePlayer()
}
#endif
