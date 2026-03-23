//
//  PlayerInformationResponseModelTests.swift
//

import XCTest
@testable import PlaybackSDK

#if !os(macOS)
final class PlayerInformationResponseModelTests: XCTestCase {

    private func decodePlayerInfo(_ json: String) throws -> PlayerInformationResponseModel {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(PlayerInformationResponseModel.self, from: data)
    }

    func testResumeMissing_TreatedAsDisabled() throws {
        let json = """
        {
          "player": {
            "bitmovin": {
              "license": "licenseKey",
              "integrations": {
                "mux": { "player_name": "Player", "env_key": "envKey" }
              }
            }
          },
          "defaults": { "player": "bitmovin" }
        }
        """

        let decoded = try decodePlayerInfo(json)
        XCTAssertEqual(decoded.player.bitmovin.integrations.resumeEnabled, false)
    }

    func testResumeNull_TreatedAsDisabled() throws {
        let json = """
        {
          "player": {
            "bitmovin": {
              "license": "licenseKey",
              "integrations": {
                "mux": { "player_name": "Player", "env_key": "envKey" },
                "resume": null
              }
            }
          },
          "defaults": { "player": "bitmovin" }
        }
        """

        let decoded = try decodePlayerInfo(json)
        XCTAssertEqual(decoded.player.bitmovin.integrations.resumeEnabled, false)
    }

    func testResumeEnabledTrue_RespectsEnabled() throws {
        let json = """
        {
          "player": {
            "bitmovin": {
              "license": "licenseKey",
              "integrations": {
                "mux": { "player_name": "Player", "env_key": "envKey" },
                "resume": { "enabled": true }
              }
            }
          },
          "defaults": { "player": "bitmovin" }
        }
        """

        let decoded = try decodePlayerInfo(json)
        XCTAssertEqual(decoded.player.bitmovin.integrations.resumeEnabled, true)
    }

    func testResumeEnabledFalse_RespectsEnabled() throws {
        let json = """
        {
          "player": {
            "bitmovin": {
              "license": "licenseKey",
              "integrations": {
                "mux": { "player_name": "Player", "env_key": "envKey" },
                "resume": { "enabled": false }
              }
            }
          },
          "defaults": { "player": "bitmovin" }
        }
        """

        let decoded = try decodePlayerInfo(json)
        XCTAssertEqual(decoded.player.bitmovin.integrations.resumeEnabled, false)
    }

    func testResumeEmptyObject_DefaultsEnabledFalse() throws {
        let json = """
        {
          "player": {
            "bitmovin": {
              "license": "licenseKey",
              "integrations": {
                "mux": { "player_name": "Player", "env_key": "envKey" },
                "resume": {}
              }
            }
          },
          "defaults": { "player": "bitmovin" }
        }
        """

        let decoded = try decodePlayerInfo(json)
        XCTAssertEqual(decoded.player.bitmovin.integrations.resumeEnabled, false)
    }
}
#endif

