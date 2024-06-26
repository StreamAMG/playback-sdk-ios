//
//  PlayerInformationAPI.swift
//  
//
//  Created by Franco Driansetti on 19/02/2024.
//
#if !os(macOS)
import Foundation
import Combine

internal protocol PlayerInformationAPI {
    func getPlayerInformation(userAgent: String?) -> AnyPublisher<PlayerInformationResponseModel, Error>
}
#endif
