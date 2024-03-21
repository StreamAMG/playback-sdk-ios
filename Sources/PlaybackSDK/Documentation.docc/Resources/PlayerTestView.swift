//
//  LoadPlayerViewTutorial.swift
//
//
//  Created by Franco Driansetti on 27/02/2024.
//

import SwiftUI
import PlaybackSDK

struct PlayerTestView: View {
    
    private let entryID = "ENTRY_ID"
    private let authorizationToken = "JWT_TOKEN"
    
    var body: some View {
        VStack {
            // Load player with the playback SDK
            PlayBackSDKManager.shared.loadPlayer(entryID: entryID, authorizationToken: authorizationToken) { error in
                handlePlaybackError(error)
            }
            .onDisappear {
                // Remove the player here
            }
            Spacer()
        }
        .padding()
    }
    
    private func handlePlaybackError(_ error: PlaybackError) {
        switch error {
        case .apiError(let statusCode, let errorMessage, let reason):
            print("\(errorMessage) Status Code \(statusCode)")
            errorMessage = "\(errorMessage) Status Code \(statusCode) Reason \(reason)"
        default:
            print("Error loading HLS stream in PlaybackUIView: \(error.localizedDescription)")
            errorMessage = "Error code and errorrMessage not found: \(error.localizedDescription)"
        }
    }
    
}
