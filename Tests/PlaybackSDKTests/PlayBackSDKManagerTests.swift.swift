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

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = PlayBackSDKManager()
        apiKey = ProcessInfo.processInfo.environment["API_KEY"]
        XCTAssertNotNil(apiKey, "API key should be provided via environment variable")
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
                XCTAssertEqual(license, "12345678-1111-1111-1111-123456789012", "Expected Bitmovin license not received")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Initialization failed with error: \(error.localizedDescription)")
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

    // Add more tests for other functionalities as needed
}
