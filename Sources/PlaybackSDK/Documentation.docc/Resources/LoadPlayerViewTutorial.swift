import Foundation

PlaybackSDKManager.shared.loadPlayer(entryID: settingsManager.entryId, authorizationToken: settingsManager.authorizationToken, onError: { error in
    // Handle the error here
    switch error {
    case .apiError(let statusCode, _):
        print("\(statusCode)")
    default:
        print("Error loading HLS stream in PlaybackUIView: \(error.localizedDescription)")
    }
})
