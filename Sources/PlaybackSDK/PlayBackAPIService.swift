//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Foundation
import Combine

class PlayBackAPIService: PlayBackAPI {
    private let baseURL = "https://api.playback.streamamg.com/v1"
    private let authorizationToken: String
    private let apiKey: String

    init(authorizationToken: String, apiKey: String) {
        self.authorizationToken = authorizationToken
        self.apiKey = apiKey
    }

    func getVideoDetails(forEntryId entryId: String) -> AnyPublisher<VideoDetails, Error> {
        guard let url = URL(string: "\(baseURL)/entry/\(entryId)") else {
            return Fail(error: PlayBackAPIError.invalidResponse).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if !authorizationToken.isEmpty {
            request.addValue(authorizationToken, forHTTPHeaderField: "Authorization")
        }
        
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: VideoDetails.self, decoder: JSONDecoder())
            .mapError { PlayBackAPIError.networkError($0) }
            .eraseToAnyPublisher()
    }
}

