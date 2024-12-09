//
//  PlaybackAPI.swift
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
internal protocol PlaybackAPI {
    
    /**
     Retrieves video details for a given entry ID.
     
     - Parameters:
        - entryId: The unique identifier of the video entry.
        - andAuthorizationToken: Optional authorization token, can be nil for free videos.
        - userAgent: Custom `User-Agent` header to use with playback requests. Can be used if there was a custom header set to start session request. Defaults to `nil`
     - Returns: A publisher emitting a result with a response model with an error or a critical error.
     */
    func getVideoDetails(forEntryId entryId: String, andAuthorizationToken: String?, userAgent: String?) -> AnyPublisher<Result<PlaybackResponseModel, Error>, Error>
}

#endif
