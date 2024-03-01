//
//  PlayerInformationResponseModel.swift
//  
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import Foundation

internal struct PlayerInformationResponseModel: Decodable {
    
    let player: PlayerInfo
    let defaults: Defaults
    
    private enum CodingKeys: String, CodingKey {
           case player
    
           case defaults
       }
}

struct PlayerInfo: Decodable {
    let bitmovin: Bitmovin
}

struct Bitmovin: Decodable {
    let license: String
    let integrations: Integrations
}

struct Integrations: Decodable {
    let mux: Mux
    let resume: Resume
}

struct Mux: Decodable {
    let playerName: String
    let envKey: String
    
    private enum CodingKeys: String, CodingKey {
        case playerName = "player_name" // Map "player_name" key to playerName property
        case envKey = "env_key"
    }

}

struct Resume: Decodable {
    let enabled: Bool
}

struct FeatureFlags: Decodable {
    let customErrorScreen: Bool
    
}

struct Defaults: Decodable {
    let player: String
}
#endif
