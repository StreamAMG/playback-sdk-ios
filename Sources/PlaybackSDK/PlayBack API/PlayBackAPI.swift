//
//  PlayBackAPIError.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import Foundation
import Combine

/**
 Protocol defining the methods required to interact with the Playback API.
 */
internal protocol PlayBackAPI {
    
    /**
     Retrieves video details for a given entry ID.
     
     - Parameters:
     - entryId: The unique identifier of the video entry.
     - andAuthorizationToken: Optional authorization token, can be nil for free videos.
     - Returns: A publisher emitting the response model or an error.
     */
    func getVideoDetails(forEntryId entryId: String, andAuthorizationToken: String?, userAgent: String?) -> AnyPublisher<PlaybackResponseModel, Error>
}

#endif
