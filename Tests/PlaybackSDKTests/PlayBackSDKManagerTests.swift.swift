//
//  PlayBackSDKManagerTests.swift.swift
//
//
//  Created by Franco Driansetti on 29/02/2024.
//

import XCTest
import Combine
@testable import PlaybackSDK

class PlayBackSDKManagerTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()
    var manager: PlayBackSDKManager!
    var apiKey: String!
    var entryID: String!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = PlayBackSDKManager()
        apiKey = ProcessInfo.processInfo.environment["API_KEY"]
        XCTAssertNotNil(apiKey, "API key should be provided via environment variable")
        entryID = ProcessInfo.processInfo.environment["ENTRY_ID"]
        XCTAssertNotNil(entryID, "API key should be provided via environment variable")
        
    }

    override func tearDownWithError() throws {
        manager = nil
        cancellables.removeAll()
        try super.tearDownWithError()
    }

    func testInitialization() throws {
        XCTAssertNotNil(manager, "Manager should not be nil after initialization")
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
            case .success(let hlsURL):
                XCTAssertNotNil(hlsURL, "HLS stream URL should not be nil")
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

    func testLoadPlayer() {
        let playerView = manager.loadPlayer(entryID: "exampleEntryID", authorizationToken: "exampleToken", onError: nil)
        // Assert that playerView is not nil or do further UI testing if possible
        XCTAssertNotNil(playerView)
    }
}
