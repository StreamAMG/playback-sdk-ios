import Foundation

// Define reason codes returned by Playback SDK
public enum PlaybackErrorReason: Equatable {
    // Http error 400
    case headerError
    case badRequestError
    case siteNotFound
    case apiKeyError
    
    // Http error 400 and 401
    case mpPartnerError
    case configurationError
    
    // Http error 401
    case tokenError
    case tooManyDevices
    case tooManyRequests
    case noEntitlement
    case noSubscription
    case notAuthenticated
    
    // Http error 401 and 440
    case noActiveSession
    
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
