//
//  File.swift
//
//
//  Created by Franco Driansetti on 19/02/2024.


import Foundation

// BitmovinPlayerWrapper.swift
class BitmovinPlayerWrapper {
//    private let playBackAPI: PlayBackAPI
//    private let configurationAPI: ConfigurationAPI
//
//    init(playBackAPI: PlayBackAPI, configurationAPI: ConfigurationAPI) {
//        self.playBackAPI = playBackAPI
//        self.configurationAPI = configurationAPI
//    }
//
//    func setupPlayer(completion: @escaping (BitmovinPlayer?) -> Void) {
//        // Retrieve necessary data from APIs
//        Task {
//            do {
//                let videoDetails = try await self.playBackAPI.getVideoDetails(forEntryId: "your_entry_id_here")
//                configurationAPI.getPlayerSettings { settings in
//                    guard let settings = settings else {
//                        print("Failed to retrieve necessary data for player setup")
//                        completion(nil)
//                        return
//                    }
//                    // Set up Bitmovin player with retrieved data
//                    let bitmovinPlayer = BitmovinPlayer(videoURL: videoDetails.media.hls, settings: settings)
//                    completion(bitmovinPlayer)
//                }
//            } catch {
//                print("Failed to retrieve video details: \(error)")
//                completion(nil)
//            }
//        }
//    }
}


