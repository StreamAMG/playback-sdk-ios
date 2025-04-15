public struct VideoPlayerConfig {
    public var playbackConfig = PlaybackConfig()
    
    public init() {}
}

public struct PlaybackConfig {
    public var autoplayEnabled: Bool = true
    public var backgroundPlaybackEnabled: Bool = true
    public var skipBackForwardButton: Bool = false
}
