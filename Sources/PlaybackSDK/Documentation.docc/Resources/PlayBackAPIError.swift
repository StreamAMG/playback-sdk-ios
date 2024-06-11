//
//  PlayBackAPIError.swift
//  
//
//  Created by Artem Yelizarov on 11.06.2024.
//

import Foundation

public enum PlayBackAPIError: Error {

  case invalidResponsePlaybackData

  case invalidPlaybackDataURL

  case invalidPlayerInformationURL

  case initializationError

  case loadHLSStreamError

  case networkError(Error)

  case apiError(statusCode: Int, message: String)
}
