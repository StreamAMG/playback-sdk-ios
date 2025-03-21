//
//  PlayerInformationAPIService.swift
//  
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import Foundation
import Combine

internal class PlayerInformationAPIService: PlayerInformationAPI {
    
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func getPlayerInformation(userAgent: String?) -> AnyPublisher<PlayerInformationResponseModel, Error> {
        guard let url = URL(string: "\(PlaybackSDKManager.shared.baseURL)/player") else {
            return Fail(error: PlaybackAPIError.invalidPlayerInformationURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        if let userAgent {
            request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: PlayerInformationResponseModel.self, decoder: JSONDecoder())
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
