import Foundation
import ActivityKit

@MainActor
final class LiveActivityController {
    static let shared = LiveActivityController()

    private var currentActivity: Any?
    private var totalSeconds: Int = 60

    private init() {}

    func start(totalSeconds: Int) {
        guard #available(iOS 16.2, *) else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        end()
        self.totalSeconds = totalSeconds

        let attributes = ArtimindActivityAttributes(
            sessionId: UUID().uuidString,
            totalSeconds: totalSeconds
        )
        let initialState = ArtimindActivityAttributes.ContentState(
            progress: 0,
            phase: .generating,
            remainingText: Self.formatRemaining(seconds: totalSeconds)
        )

        do {
            let activity = try Activity<ArtimindActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            currentActivity = nil
        }
    }

    func update(progress: Double) {
        guard #available(iOS 16.2, *) else { return }
        guard let activity = currentActivity as? Activity<ArtimindActivityAttributes> else { return }

        let clamped = max(0, min(1, progress))
        let remainingSec = max(0, Int(Double(totalSeconds) * (1 - clamped)))
        let state = ArtimindActivityAttributes.ContentState(
            progress: clamped,
            phase: clamped >= 1 ? .ready : .generating,
            remainingText: Self.formatRemaining(seconds: remainingSec)
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func markFailed() {
        guard #available(iOS 16.2, *) else { return }
        guard let activity = currentActivity as? Activity<ArtimindActivityAttributes> else { return }
        let state = ArtimindActivityAttributes.ContentState(
            progress: 0,
            phase: .failed,
            remainingText: "—"
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func end() {
        guard #available(iOS 16.2, *) else { return }
        guard let activity = currentActivity as? Activity<ArtimindActivityAttributes> else { return }
        currentActivity = nil

        let finalState = ArtimindActivityAttributes.ContentState(
            progress: 1,
            phase: .ready,
            remainingText: "Done"
        )
        Task {
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
        }
    }

    private static func formatRemaining(seconds: Int) -> String {
        if seconds >= 60 {
            let m = seconds / 60
            return "\(m)m"
        }
        return "\(seconds)s"
    }
}
