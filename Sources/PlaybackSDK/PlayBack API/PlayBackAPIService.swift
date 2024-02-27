//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Foundation
import Combine

/**
 A service class responsible for handling playback API requests.
 */
internal class PlayBackAPIService: PlayBackAPI {
    
    /// The API key required for authentication.
    private let apiKey: String

    /**
     Initializes the playback API service with the provided API key.
     
     - Parameter apiKey: The API key required for authentication.
     */
    init(apiKey: String) {
        self.apiKey = apiKey
    }

    /**
     Retrieves video details for a given entry ID.
     
     - Parameters:
        - entryId: The unique identifier of the video entry.
        - andAuthorizationToken: Optional authorization token, can be nil for free videos.
     - Returns: A publisher emitting the response model or an error.
     */
    func getVideoDetails(forEntryId entryId: String, andAuthorizationToken: String?) -> AnyPublisher<PlaybackResponseModel, Error> {
        guard let url = URL(string: "\(PlayBackSDKManager.shared.baseURL)/entry/\(entryId)") else {
            return Fail(error: PlayBackAPIError.invalidResponse).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /// JWT Token can be nil for free videos.
        if let authorizationTokenExist = andAuthorizationToken, !authorizationTokenExist.isEmpty {
            request.addValue("Bearer \(authorizationTokenExist)", forHTTPHeaderField: "Authorization")
        }
        
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: PlaybackResponseModel.self, decoder: JSONDecoder())
            .mapError { PlayBackAPIError.networkError($0) }
            .eraseToAnyPublisher()
    }
}


