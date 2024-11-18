//
//  PlayBackSDKManager.swift
//
//
//  Created by Franco Driansetti on 20/02/2024.
//
#if !os(macOS)
import Foundation
import Combine
import SwiftUI

// Errors.swift

// Define custom error types for SDK-related errors
public enum SDKError: Error {
   case initializationError
   case missingLicense
   case loadHLSStreamError
}

// Define reason codes returned by Playback SDK
public enum PlaybackErrorReason: Equatable {
    // Http error 400
    case headerError
    case badRequestError
    case siteNotFound
    case configurationError
    case apiKeyError
    case mpPartnerError
    
    // Http error 401
    case tokenError
    case tooManyDevices
    case tooManyRequests
    case noEntitlement
    case noSubscription
    case noActiveSession
    case notAuthenticated
    
    // Http error 404
    case noEntityExist
    
    // Unknown error with associated custom message
    case unknownError(String)

    init(fromString value: String) {
        switch value.uppercased() {
        case "HEADER_ERROR": self = .headerError
        case "BAD_REQUEST_ERROR": self = .badRequestError
        case "SITE_NOT_FOUND": self = .siteNotFound
        case "CONFIGURATION_ERROR": self = .configurationError
        case "API_KEY_ERROR": self = .apiKeyError
        case "MP_PARTNER_ERROR": self = .mpPartnerError
        case "TOKEN_ERROR": self = .tokenError
        case "TOO_MANY_DEVICES": self = .tooManyDevices
        case "TOO_MANY_REQUESTS": self = .tooManyRequests
        case "NO_ENTITLEMENT": self = .noEntitlement
        case "NO_SUBSCRIPTION": self = .noSubscription
        case "NO_ACTIVE_SESSION": self = .noActiveSession
        case "NOT_AUTHENTICATED": self = .notAuthenticated
        case "NO_ENTITY_EXIST": self = .noEntityExist
        default: self = .unknownError(value)
        }
    }
}


/**
 Define the errors that can occur during API interactions
 */
public enum PlayBackAPIError: Error {
    
    case invalidResponsePlaybackData
    case invalidPlaybackDataURL
    case invalidPlayerInformationURL
    case initializationError
    case loadHLSStreamError

    case networkError(Error)
    case apiError(statusCode: Int, message: String, reason: PlaybackErrorReason)
}


/// Singleton responsible for initializing the SDK and managing player information
public class PlayBackSDKManager {
    
    //MARK: Piblic Properties
    /// Singleton instance of the `PlayBackSDKManager`.
    public static let shared = PlayBackSDKManager()
    
    // MARK: Private properties
    private var playerInfoAPI: PlayerInformationAPI?
    private var playBackAPI: PlayBackAPI?
    private var userAgentHeader: String?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Internal properties
    /// Bitmovin license key.
    internal var bitmovinLicense: String?
    internal var amgAPIKey: String?
    internal var baseURL = "https://api.playback.streamamg.com/v1"
    
    // MARK: Public fuctions
    
    /// Initializes the `PlayBackSDKManager`.
    public init() {}
    
    /// Initializes the SDK with the provided API key.
    /// This fuction must be called in the AppDelegate
    ///
    /// - Parameters:
    ///   - apiKey: The API key for initializing the SDK.
    ///   - baseURL: The base URL for API endpoints. Defaults to `nil`.
    ///   - userAgent: Custom `User-Agent` header to use with playback requests. Can be used if there was a custom header set to start session request. Defaults to `nil`
    ///   - completion: A closure to be called after initialization.
    ///                 It receives a result indicating success or failure.
    public func initialize(apiKey: String, baseURL: String? = nil, userAgent: String? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty else {
            completion(.failure(SDKError.initializationError))
            return
        }
        
        if let baseURLExist = baseURL {
            self.baseURL = baseURLExist
        }
        
        amgAPIKey = apiKey
        userAgentHeader = userAgent
        playerInfoAPI = PlayerInformationAPIService(apiKey: apiKey)
        let playBackAPIService = PlayBackAPIService(apiKey: apiKey)
        self.playBackAPI = playBackAPIService
        /// Fetching Bitmovin license
        fetchPlayerInfo(completion: completion)
    }
    
    /**
     Loads a video player with the specified entry ID and authorization token.
     
     - Parameters:
     - entryID: The unique identifier of the video entry to be loaded.
     - authorizationToken: The token used for authorization to access the video content.
     - userId: User identifier to be tracked in analytics
     
     - Returns: A view representing the video player configured with the provided entry ID and authorization token.
     
     Example usage:
     ```swift
     let playerView = loadPlayer(entryID: "exampleEntryID", authorizationToken: "exampleToken", userId: "1234abcd")
     */
    public func loadPlayer(
        entryID: String,
        authorizationToken: String? = nil,
        mediaTitle: String? = nil,
        userId: String? = nil,
        onError: ((PlayBackAPIError) -> Void)?
    ) -> some View {

        PlaybackUIView(
            entryId: entryID,
            authorizationToken: authorizationToken,
            mediaTitle: mediaTitle,
            userId: userId,
            onError: onError
        )
        .id(entryID)
    }
    
    // MARK: Private fuctions
    
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
        
        playerInfoAPIExist.getPlayerInformation(userAgent: userAgentHeader)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    print("Player license aquired.")
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
    internal func loadHLSStream(forEntryId entryId: String, andAuthorizationToken: String?, completion: @escaping (Result<URL, PlayBackAPIError>) -> Void) {
        guard let playBackAPIExist = playBackAPI else {
            completion(.failure(PlayBackAPIError.initializationError))
            return
        }
        
        // Call the /entry endpoint for the given entry ID
        playBackAPIExist.getVideoDetails(
            forEntryId: entryId,
            andAuthorizationToken: andAuthorizationToken,
            userAgent: userAgentHeader
        )
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    if let playbackAPIError = error as? PlayBackAPIError {
                        completion(.failure(playbackAPIError))
                    } else {
                        completion(.failure(.networkError(error)))
                    }
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
                    completion(.failure(PlayBackAPIError.loadHLSStreamError))
                    return
                }
                
                // Call the completion handler with the HLS stream URL
                completion(.success(hlsURL))
            })
            .store(in: &cancellables)
    }
}


#endif
