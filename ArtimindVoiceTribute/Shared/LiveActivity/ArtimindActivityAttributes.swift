import Foundation
import ActivityKit

@available(iOS 16.2, *)
struct ArtimindActivityAttributes: ActivityAttributes {
    public enum Phase: String, Codable, Hashable {
        case generating
        case ready
        case failed
    }

    public struct ContentState: Codable, Hashable {
        var progress: Double
        var phase: Phase
        var remainingText: String
    }

    var sessionId: String
    var totalSeconds: Int
}
