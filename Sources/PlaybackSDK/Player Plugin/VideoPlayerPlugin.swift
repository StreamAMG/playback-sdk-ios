//
//  VideoPlayerPlugin.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import AVFoundation
import SwiftUI

// Protocol for defining a video player plugin
public protocol VideoPlayerPlugin: AnyObject {
    
    var name: String { get }
    var version: String { get }
    
    func setup(config: VideoPlayerConfig)
    
    // TODO: add event
    /// func handleEvent(event: BitmovinPlayerCore.PlayerEvent)
    
    func playerView(hlsURLString: String, title: String, userId: String?) -> AnyView
    
    func play()
    
    func pause() 
    
    func removePlayer() 
}
#endif
