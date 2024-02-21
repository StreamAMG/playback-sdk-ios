//
//  File.swift
//  
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Foundation
import Combine

public protocol PlayerInformationAPI {
    func getPlayerInformation() -> AnyPublisher<PlayerInformationResponseModel, Error>
}
