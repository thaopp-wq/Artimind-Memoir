import Foundation
import SwiftUI

@MainActor
final class GenerationManager: ObservableObject {
    static let shared = GenerationManager()

    @Published var progress: CGFloat = 0
    @Published var isGenerating: Bool = false
    @Published var hasPendingResult: Bool = false
    @Published var lastThemeTitle: String? = nil
    @Published var selectedTheme: AlbumThemeSpec? = nil
    @Published var isPro: Bool = false
    /// QA helper — when true, the next face-detection run is forced to fail so
    /// the failed-detection screen can be inspected without hunting for an asset
    /// that actually has no face. Reset to false after consumption.
    @Published var forceDetectionFailure: Bool = false
    /// True while GeneratingView is on-screen. ContentView reads this to suppress
    /// the "your album is ready" alert when the user is already watching progress
    /// (the screen auto-navigates to Result on completion instead).
    @Published var isGeneratingScreenVisible: Bool = false
    /// PHAsset.localIdentifier values that failed face detection on the most
    /// recent run. AddPhotosView reads this to overlay a "Photo Not Eligible"
    /// state on those assets, and clears them as the user removes/replaces them.
    @Published var ineligibleAssetIDs: Set<String> = []

    private var timer: Timer?
    private let totalDuration: TimeInterval = 60
    private let tickInterval: TimeInterval = 0.5

    private init() {}

    func start(themeTitle: String? = nil) {
        if isGenerating { return }
        progress = 0
        isGenerating = true
        hasPendingResult = false
        lastThemeTitle = themeTitle
        LiveActivityController.shared.start(totalSeconds: Int(totalDuration))
        scheduleTimer()
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        isGenerating = false
        progress = 0
        hasPendingResult = false
        LiveActivityController.shared.end()
    }

    func acknowledgeResult() {
        hasPendingResult = false
    }

    private func scheduleTimer() {
        timer?.invalidate()
        let step = CGFloat(tickInterval / totalDuration)
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] activeTimer in
            Task { @MainActor in
                guard let self else { activeTimer.invalidate(); return }
                if self.progress < 1 {
                    self.progress = min(1, self.progress + step)
                    LiveActivityController.shared.update(progress: Double(self.progress))
                } else {
                    activeTimer.invalidate()
                    self.timer = nil
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    LiveActivityController.shared.end()
                    self.isGenerating = false
                    self.hasPendingResult = true
                    NotificationCenter.default.post(name: .generationDidComplete, object: nil)
                }
            }
        }
    }
}

extension Notification.Name {
    static let generationDidComplete = Notification.Name("generationDidComplete")
    static let openPendingResult = Notification.Name("openPendingResult")
}
