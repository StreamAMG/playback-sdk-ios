//
//  PlaybackSDKManagerTests.swift.swift
//
//
//  Created by Franco Driansetti on 29/02/2024.
//

import XCTest
import Combine
@testable import PlaybackSDK

class PlaybackSDKManagerTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()
    var manager: PlaybackSDKManager!
    var apiKey: String!
    var entryID: String!
    var playlistEntryID: [String]!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = PlaybackSDKManager()
        apiKey = TestConfig.testAPIKey
        XCTAssertNotNil(apiKey, "API key should be provided via environment variable")
        entryID = TestConfig.testEntryID
        XCTAssertNotNil(entryID, "Entry ID should be provided via environment variable")
        playlistEntryID = TestConfig.testPlaylistEntryID
    }

    override func tearDownWithError() throws {
        manager = nil
        cancellables.removeAll()
        try super.tearDownWithError()
    }

    func testInitialization() throws {
        XCTAssertNotNil(manager, "Manager should not be nil after initialization")
    }
    
    func testInitializeWithCustomUserAgent() {
        let expectation = expectation(description: "Initialization expectation")

        manager.initialize(apiKey: apiKey, userAgent: "IOS Tests") { result in
            switch result {
            case .success(let license):
                XCTAssertNotNil(license, "Bitmovin license should not be nil")
                XCTAssertFalse(license.isEmpty, "Bitmovin license should not be empty")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Initialization failed with error: \(error.localizedDescription)")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testInitializeWithValidAPIKey() {
        let expectation = expectation(description: "Initialization expectation")

        manager.initialize(apiKey: apiKey) { result in
            switch result {
            case .success(let license):
                XCTAssertNotNil(license, "Bitmovin license should not be nil")
                XCTAssertFalse(license.isEmpty, "Bitmovin license should not be empty")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Initialization failed with error: \(error.localizedDescription)")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLoadAllHLSStreams() {
        let initializationExpectation = expectation(description: "SDK initialization")
        manager.initialize(apiKey: apiKey) { result in
            switch result {
            case .success:
                initializationExpectation.fulfill()
            case .failure(let error):
                XCTFail("SDK initialization failed with error: \(error.localizedDescription)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        let videoDetailsExpectation = expectation(description: "Video details loading expectation")
        manager.loadAllHLSStream(forEntryIds: playlistEntryID, andAuthorizationToken: nil) { result in
            switch result {
            case .success(let videoDetails):
                XCTAssertNotNil(videoDetails.0, "Video details should not be nil")
                XCTAssertTrue(videoDetails.1.isEmpty, "Playlist errors should be void")
                videoDetailsExpectation.fulfill()
            case .failure(let error):
                XCTFail("Loading Playlist video details failed with error: \(error.localizedDescription)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLoadAllHLSStreamsWithError() {
        let initializationExpectation = expectation(description: "SDK initialization")
        manager.initialize(apiKey: apiKey) { result in
            switch result {
            case .success:
                initializationExpectation.fulfill()
            case .failure(let error):
                XCTFail("SDK initialization failed with error: \(error.localizedDescription)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        let videoDetailsExpectation = expectation(description: "Video details loading expectation")
        var playlistEntryIDwithError: [String] = playlistEntryID
        // Adding a fake entryId to check that the error callback works
        playlistEntryIDwithError.append("0_xxxxxxxx")
        manager.loadAllHLSStream(forEntryIds: playlistEntryIDwithError, andAuthorizationToken: nil) { result in
            switch result {
            case .success(let videoDetails):
                XCTAssertNotNil(videoDetails.0, "Video details should not be nil")
                XCTAssertTrue(videoDetails.1.isEmpty == false, "Playlist errors should be not empty")
                videoDetailsExpectation.fulfill()
            case .failure(let error):
                XCTFail("Loading Playlist video details failed with error: \(error.localizedDescription)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testLoadHLSStream() {
        let initializationExpectation = expectation(description: "SDK initialization")
        manager.initialize(apiKey: apiKey) { result in
            switch result {
            case .success:
                initializationExpectation.fulfill()
            case .failure(let error):
                XCTFail("SDK initialization failed with error: \(error.localizedDescription)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)

        let hlsExpectation = expectation(description: "HLS stream loading expectation")
        manager.loadHLSStream(forEntryId: entryID, andAuthorizationToken: nil) { result in
            switch result {
            case .success(let videoDetail):
                XCTAssertNotNil(videoDetail.media?.hls, "HLS stream URL should not be nil")
                hlsExpectation.fulfill()
            case .failure(let error):
                XCTFail("Loading HLS stream failed with error: \(error.localizedDescription)")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testInitializeWithEmptyAPIKey() {
        let expectation = expectation(description: "Initialization expectation")

        manager.initialize(apiKey: "") { result in
            switch result {
            case .success:
                XCTFail("Initialization should fail with empty API key")
            case .failure(let error):
                XCTAssertEqual(error as? SDKError, SDKError.initializationError, "Initialization should fail with initialization error")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFailedEntryId() {
        let initializationExpectation = expectation(description: "SDK initialization")
        manager.initialize(apiKey: apiKey) { result in
            switch result {
            case .success:
                initializationExpectation.fulfill()
            case .failure(let error):
                XCTFail("SDK initialization failed with error: \(error.localizedDescription)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)

        let hlsExpectation = expectation(description: "Empty entry id loading expectation")
        manager.loadHLSStream(forEntryId: "", andAuthorizationToken: nil) { result in
            switch result {
            case .success(_):
                XCTFail("Empty entry id provided but got HLS stream")
            case .failure(let error):
                switch error {
                case .networkError(_):
                    hlsExpectation.fulfill()
                default:
                    hlsExpectation.fulfill()
                }
                
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLoadPlayer() {
        let playerView = manager.loadPlayer(entryID: "exampleEntryID", authorizationToken: "exampleToken", onError: { _ in })
        // Assert that playerView is not nil or do further UI testing if possible
        XCTAssertNotNil(playerView)
    }
    
    func testLoadPlaylist() {
        let playerView = manager.loadPlaylist(entryIDs: playlistEntryID, authorizationToken: nil, onErrors: { _ in })
        // Assert that playerView is not nil or do further UI testing if possible
        XCTAssertNotNil(playerView)
    }
}
