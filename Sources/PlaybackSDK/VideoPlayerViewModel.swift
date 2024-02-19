//
//  File.swift
//  
//
//  Created by Franco Driansetti on 19/02/2024.
//

import Foundation
import Combine

class VideoPlayerViewModel: ObservableObject {
    private let playBackAPI: PlayBackAPI
    private var cancellables = Set<AnyCancellable>()

    @Published var videoDetails: VideoDetails?

    init(playBackAPI: PlayBackAPI) {
        self.playBackAPI = playBackAPI
    }

    func fetchVideoDetails(forEntryId entryId: String, completion: @escaping () -> Void) {
        playBackAPI.getVideoDetails(forEntryId: entryId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching video details: \(error)")
                }
            }, receiveValue: { [weak self] videoDetails in
                // Print the received video details
                print("Received video details: \(videoDetails)")

                // Set the received video details to the published property
                self?.videoDetails = videoDetails
                completion() // Call completion handler when fetching is completed
            })
            .store(in: &cancellables)
    }


}



