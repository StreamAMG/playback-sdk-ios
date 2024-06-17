public struct VideoPlayerConfig {
    public var playbackConfig = PlaybackConfig()
    
    public init() {}
}

public class PlaybackConfig {
    public var autoplayEnabled: Bool = true
    public var backgroundPlaybackEnabled: Bool = true
}
