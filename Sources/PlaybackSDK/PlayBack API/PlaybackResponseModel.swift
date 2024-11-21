//
//  PlaybackResponseModel.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import Foundation

// Struct representing the response model for playback data, conforming to the Decodable protocol.
public struct PlaybackResponseModel: Decodable {
    
    public let message: String?
    public let reason: String?
    public let id: String?
    public let name: String?
    public let description: String?
    public let thumbnail: URL?
    public let duration: String?
    public let media: Media?
    public let playFrom: Int?
    public let adverts: [Advert]?
    public let coverImg: CoverImages?
    public var entryId: String?
    
    public struct Media: Decodable {
        public let hls: String?
        public let mpegdash: String?
        public let applehttp: String?
    }
    
    public struct Advert: Decodable {
        public let adType: String?
        public let id: String?
        public let position: String?
        public let persistent: Bool?
        public let discardAfterPlayback: Bool?
        public let url: URL?
        public let preloadOffset: Int?
        public let skippableAfter: Int?
    }
    
    public struct CoverImages: Decodable {
        public let _360: URL?
        public let _720: URL?
        public let _1080: URL?
        
        public enum CodingKeys: String, CodingKey {
            case _360 = "360"
            case _720 = "720"
            case _1080 = "1080"
        }
        /**
         Initializes the CoverImages struct with decoder.
         
         - Parameter decoder: The decoder to read data from.
         */
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _360 = try container.decodeIfPresent(String.self, forKey: ._360).flatMap { URL(string: $0) }
            _720 = try container.decodeIfPresent(String.self, forKey: ._720).flatMap { URL(string: $0) }
            _1080 = try container.decodeIfPresent(String.self, forKey: ._1080).flatMap { URL(string: $0) }
        }
    }
    
}
#endif
