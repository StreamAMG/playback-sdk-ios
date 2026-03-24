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
    let resume: Resume?

    // When the backend omits `resume`, treat it as disabled.
    var resumeEnabled: Bool { resume?.enabled ?? false }
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Support absent `enabled` and common primitive variants.
        let enabledBool: Bool? = try? container.decodeIfPresent(Bool.self, forKey: .enabled)
        if let enabledBool {
            self.enabled = enabledBool
            return
        }

        let enabledInt: Int? = try? container.decodeIfPresent(Int.self, forKey: .enabled)
        if let enabledInt {
            self.enabled = enabledInt != 0
            return
        }

        let enabledString: String? = try? container.decodeIfPresent(String.self, forKey: .enabled)
        if let enabledString {
            switch enabledString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "true", "1", "yes", "y":
                self.enabled = true
            default:
                self.enabled = false
            }
            return
        }

        // Missing key -> default to false.
        self.enabled = false
    }

    private enum CodingKeys: String, CodingKey {
        case enabled
    }
}

struct FeatureFlags: Decodable {
    let customErrorScreen: Bool
    
}

struct Defaults: Decodable {
    let player: String
}
#endif
