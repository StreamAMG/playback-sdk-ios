//
//  File.swift
//
//
//  Created by Franco Driansetti on 20/02/2024.
//

import Foundation
import Combine

// Errors.swift
// Define custom error types for SDK-related errors

public enum SDKError: Error {
    case initializationError
    case missingLicense
    case loadHLSStreamError
    
}

/// Responsible for initializing the SDK and managing player information
public class PlayBackSDKManager {
    
    //MARK: Piblic Properties
    /// Singleton instance of the `PlayBackSDKManager`.
    public static let shared = PlayBackSDKManager()
    
    // MARK: Private properties
    private var playerInfoAPI: PlayerInformationAPI?
    private var playBackAPI: PlayBackAPI?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Internal properties
    /// Bitmovin license key.
    internal var bitmovinLicense: String?
    internal var amgAPIKey: String?
    /// Initializes the `PlayBackSDKManager`.
    public init() {}
    
    /// Initializes the SDK with the provided API key.
    /// - Parameters:
    ///   - apiKey: The API key for initializing the SDK.
    ///   - completion: A closure to be called after initialization.
    ///                 It receives a result indicating success or failure.
    public func initialize(apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(SDKError.initializationError))
            return
        }
        
        amgAPIKey = apiKey
        playerInfoAPI = PlayerInformationAPIService(apiKey: apiKey)
        let playBackAPIService = PlayBackAPIService(apiKey: apiKey)
        self.playBackAPI = playBackAPIService
        /// Fetching Bitmovin license
        fetchPlayerInfo(completion: completion)
    }
    
    /// Fetches player information from the player information API.
    ///
    /// - Parameters:
    ///   - completion: A closure to be called after fetching player information.
    ///                 It receives a result indicating success or failure.
    private func fetchPlayerInfo(completion: @escaping (Result<String, Error>) -> Void) {
        guard let playerInfoAPIExist = playerInfoAPI else {
            completion(.failure(SDKError.initializationError))
            return
        }
        
        playerInfoAPIExist.getPlayerInformation()
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    print("License aquired.")
                    break
                }
            }, receiveValue: { playerInfo in
                // Print the received player information
                print("Received player information: \(playerInfo)")
                
                // Extract the Bitmovin license
                if playerInfo.player.bitmovin.license.isEmpty {
                    completion(.failure(SDKError.missingLicense))
                    return
                }
                
                // Set the received Bitmovin license
                self.bitmovinLicense = playerInfo.player.bitmovin.license
                
                // Call the completion handler with success
                completion(.success(playerInfo.player.bitmovin.license))
            })
            .store(in: &cancellables)
    }
    
    /// Loads an HLS stream for the given entry ID.
    /// - Parameters:
    ///   - entryId: The ID of the video entry.
    ///   - authorizationToken: Authorization token for accessing the video entry.
    ///   - completion: A closure to be called after loading the HLS stream.
    ///                 It receives a result containing the HLS stream URL or an error.
    func loadHLSStream(forEntryId entryId: String, andAuthorizationToken: String?, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let playBackAPIExist = playBackAPI else {
            completion(.failure(SDKError.initializationError))
            return
        }
        
        // Call the /entry endpoint for the given entry ID
        playBackAPIExist.getVideoDetails(forEntryId: entryId, andAuthorizationToken: andAuthorizationToken)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    print("Video details fetched successfully.")
                    break
                }
            }, receiveValue: { videoDetails in
                // Print the received video details
                print("Received video details: \(videoDetails)")
                
                // Extract the HLS stream URL from video details
                guard let hlsURLString = videoDetails.media?.hls,
                      let hlsURL = URL(string: hlsURLString) else {
                    completion(.failure(SDKError.loadHLSStreamError))
                    return
                }
                
                // Call the completion handler with the HLS stream URL
                completion(.success(hlsURL))
            })
            .store(in: &cancellables)
    }
}


