//
//  MockPlayerInformationAPI.swift
//
//
//  Created by Franco Driansetti on 29/02/2024.
//

import Foundation
import Combine
@testable import PlaybackSDK // Replace YourModuleName with the actual name of your module

class MockPlayerInformationAPI: PlayerInformationAPI {
    
    func getPlayerInformation() -> AnyPublisher<PlayerInformationResponseModel, Error> {
        let mockResponse = PlayerInformationResponseModel(
            player: PlayerInfo(
                bitmovin: Bitmovin(
                    license: "12345678-1111-1111-1111-123456789012",
                    integrations: Integrations(
                        mux: Mux(
                            playerName: "some name",
                            envKey: "env_key_123"
                        ),
                        resume: Resume(
                            enabled: true
                        )
                    )
                )
            ),
            defaults: Defaults(
                player: "bitmovin"
            )
        )
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

