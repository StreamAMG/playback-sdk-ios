//
//  File.swift
//  
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Foundation
import Combine

// Define the errors that can occur during API interactions
enum PlayBackAPIError: Error {
    case invalidResponse
    case networkError(Error)
    case apiError(statusCode: Int, message: String)
}


protocol PlayBackAPI {
    func getVideoDetails(forEntryId entryId: String) -> AnyPublisher<VideoDetails, Error>
}

