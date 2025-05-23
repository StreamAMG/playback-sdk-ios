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
    
    func playerView(videoDetails: [PlaybackVideoDetails], entryIDToPlay: String?, authorizationToken: String?, analyticsViewerId: String?) -> AnyView
    
    func play()
    
    func pause()
    
    func playNext()
    
    func playPrevious()
    
    func playLast()
    
    func playFirst()
    
    func seek(_ entryId: String, completion: @escaping (Bool) -> Void)
    
    func activeEntryId() -> String?
    
    func removePlayer()
}
#endif
