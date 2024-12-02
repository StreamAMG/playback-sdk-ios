//
//  PlaybackVideoDetails.swift
//  PlaybackSDK
//
//  Created by Stefano Russello on 29/11/24.
//

#if !os(macOS)
import Foundation

public class PlaybackVideoDetails {
    
    public var videoId: String
    public var url: String?
    public var title: String?
    public var thumbnail: String?
    public var description: String?
    
    public init(videoId: String, url: String? = nil, title: String? = nil, thumbnail: String? = nil, description: String? = nil) {
        self.videoId = videoId
        self.url = url
        self.title = title
        self.thumbnail = thumbnail
        self.description = description
    }
}

#endif
