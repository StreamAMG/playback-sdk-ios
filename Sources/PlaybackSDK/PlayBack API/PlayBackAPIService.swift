//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Foundation
import Combine

class PlayBackAPIService: PlayBackAPI {
  
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func getVideoDetails(forEntryId entryId: String, andAuthorizationToken: String?) -> AnyPublisher<PlaybackResponseModel, Error> {
        guard let url = URL(string: "\(PlayBackSDKManager.shared.baseURL)/entry/\(entryId)") else {
            return Fail(error: PlayBackAPIError.invalidResponse).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /// JWT Token can be nil for free videos.
        if let authorizationTokenExist = andAuthorizationToken {
            request.addValue(authorizationTokenExist, forHTTPHeaderField: "Authorization")
        }
        
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: PlaybackResponseModel.self, decoder: JSONDecoder())
            .mapError { PlayBackAPIError.networkError($0) }
            .eraseToAnyPublisher()
    }
}

