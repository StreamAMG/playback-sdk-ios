//
//  PlaybackResponseModel.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Foundation

// Struct representing the response model for playback data, conforming to the Decodable protocol.
internal struct PlaybackResponseModel: Decodable {
    let message: String?
    let id: String?
    let name: String?
    let description: String?
    let thumbnail: URL?
    let duration: String?
    let media: Media?
    let playFrom: Int?
    let adverts: [Advert]?
    let coverImg: CoverImages?
    
    struct Media: Decodable {
        let hls: String?
        let mpegdash: String?
        let applehttp: String?
    }
    
    struct Advert: Decodable {
        let adType: String?
        let id: String?
        let position: String?
        let persistent: Bool?
        let discardAfterPlayback: Bool?
        let url: URL?
        let preloadOffset: Int?
        let skippableAfter: Int?
    }
    
    struct CoverImages: Decodable {
        let _360: URL?
        let _720: URL?
        let _1080: URL?
        
        enum CodingKeys: String, CodingKey {
            case _360 = "360"
            case _720 = "720"
            case _1080 = "1080"
        }
        /**
         Initializes the CoverImages struct with decoder.
         
         - Parameter decoder: The decoder to read data from.
         */
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _360 = try container.decodeIfPresent(String.self, forKey: ._360).flatMap { URL(string: $0) }
            _720 = try container.decodeIfPresent(String.self, forKey: ._720).flatMap { URL(string: $0) }
            _1080 = try container.decodeIfPresent(String.self, forKey: ._1080).flatMap { URL(string: $0) }
        }
    }
    
}

