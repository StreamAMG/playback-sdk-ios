//
//  PlaybackAPIService.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import Foundation
import Combine

/**
 A service class responsible for handling playback API requests.
 */
internal class PlaybackAPIService: PlaybackAPI {

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
     - Returns: A publisher emitting a result with a response model with an error or a critical error.
     */
    func getVideoDetails(
        forEntryId entryId: String,
        andAuthorizationToken: String?,
        userAgent: String?
    ) -> AnyPublisher<Result<PlaybackResponseModel, Error>, Error> {
        guard let url = URL(string: "\(PlaybackSDKManager.shared.baseURL)/entry/\(entryId)") else {
            return Fail(error: PlaybackAPIError.invalidPlaybackDataURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /// JWT Token can be nil for free videos.
        if let authorizationTokenExist = andAuthorizationToken, !authorizationTokenExist.isEmpty {
            request.addValue("Bearer \(authorizationTokenExist)", forHTTPHeaderField: "Authorization")
        }

        if let userAgent, !userAgent.isEmpty {
            request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        }

        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(PlaybackAPIError.invalidResponsePlaybackData)
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    if let response = try? JSONDecoder().decode(PlaybackResponseModel.self, from: data) {
                        return .success(response)
                    } else {
                        return .failure(PlaybackAPIError.invalidResponsePlaybackData)
                    }
                default:
                    let decoder = JSONDecoder()
                    if let errorResponse = try? decoder.decode(PlaybackResponseModel.self, from: data) {       
                        let errorReason = errorResponse.reason ?? "Unknown authentication error reason"
                        return .failure(PlaybackAPIError.apiError(statusCode: httpResponse.statusCode, message: errorResponse.message ?? "Unknown authentication error message", reason: PlaybackErrorReason(fromString: errorReason)))
                    } else {
                        let errorReason = "Unknown authentication error reason"
                        return .failure(PlaybackAPIError.apiError(statusCode: httpResponse.statusCode, message: "Unknown authentication error", reason: PlaybackErrorReason(fromString: errorReason)))
                    }
                }
            }
            .mapError { error in
                if let apiError = error as? PlaybackAPIError {
                    return apiError
                } else {
                    return PlaybackAPIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}


#endif
