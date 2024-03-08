Playback SDK
------------

[![Swift](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/swift.yml/badge.svg)](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/swift.yml)

[![pages-build-deployment](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/StreamAMG/playback-sdk-ios/actions/workflows/pages/pages-build-deployment)

This library simplifies integrating video playback functionalities into OTT applications. It provides a unified interface for interacting with video APIs and managing playback logic.

**Key Features:**

-   **Abstraction:** Hides the complexities of underlying video APIs, allowing you to focus on the core playback experience.
-   **Flexibility:** Supports different video providers and allows the creation of custom playback plugins for extended functionalities.
-   **Error Handling:** Provides mechanisms to handle potential issues during playback and notify your application.

**Supported Platforms and Version**

- Platforms: iOS 14 and later

**Installation**

1.  Add the Playback SDK dependency to your project using Swift Package Manager.

Swift

```
dependencies: [
    .package(url: "https://github.com/StreamAMG/playback-sdk-ios", .branch("main"))
]

```

2.  Import the `PlaybackSDK` module in your Swift files.

Swift

```
import PlaybackSDK

```


**Resources:**

- **Tutorial:** [Tutorial](https://streamamg.github.io/playback-sdk-ios/tutorials/table-of-contents/#resources)
- **Demo app:** [GitHub Repository](https://github.com/StreamAMG/playback-demo-ios)
- **Stoplight API documentation:** [Documentation](https://streamamg.stoplight.io)

**Collaboration:**

To update the documentation, follow these steps:

1. Make changes to the documentation code.
2. Build the documentation following the instructions in [this URL](https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/publishing-to-github-pages/).
3. Merge the code into the `gh-pages` branch.

