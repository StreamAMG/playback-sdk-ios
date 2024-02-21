//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import SwiftUI

public class VideoPlayerPluginManager: ObservableObject {
    public static let shared = VideoPlayerPluginManager()
    @Published public var selectedPlugin: VideoPlayerPlugin?
    
    private init() {}
    
    public func registerPlugin(_ plugin: VideoPlayerPlugin) {
        DispatchQueue.main.async {
            self.selectedPlugin = plugin
        }
    }
}



