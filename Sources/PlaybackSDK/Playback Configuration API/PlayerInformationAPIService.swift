//
//  File.swift
//  
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Foundation
import Combine

internal class PlayerInformationAPIService: PlayerInformationAPI {
    
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func getPlayerInformation() -> AnyPublisher<PlayerInformationResponseModel, Error> {
        guard let url = URL(string: "\(PlayBackSDKManager.shared.baseURL)/player") else {
            return Fail(error: PlayBackAPIError.invalidResponse).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: PlayerInformationResponseModel.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? PlayBackAPIError {
                    return apiError
                } else {
                    return PlayBackAPIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
