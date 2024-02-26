//
//  File.swift
//  
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Foundation
import Combine

/**
Define the errors that can occur during API interactions
 */
enum PlayBackAPIError: Error {
    
    /// Indicates an invalid response received from the API.
    case invalidResponse
    
    /// Indicates a network error occurred during the API interaction.
    case networkError(Error)
    
    /**
     Indicates an error response received from the API.
     
     - Parameters:
        - statusCode: The HTTP status code of the error response.
        - message: The error message provided by the API.
     */
    case apiError(statusCode: Int, message: String)
}

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
    func getVideoDetails(forEntryId entryId: String, andAuthorizationToken: String?) -> AnyPublisher<PlaybackResponseModel, Error>
}

