import Foundation

extension Notification.Name {
    static let popGenerationFlow = Notification.Name("popGenerationFlow")
    /// Pops the user back to AddPhotosView from anywhere downstream of it
    /// (detecting / failed / paywall / generating), so they can change their
    /// selection without re-running detection or restarting from the theme.
    static let returnToAddPhotos = Notification.Name("returnToAddPhotos")
    /// Pops the wedding tribute wizard flow back to the Moments tab (Wedding tag).
    static let popWeddingFlow = Notification.Name("popWeddingFlow")
    /// Pops restore/colorize flow back to PersonTimelineView
    static let popRestoreFlow = Notification.Name("popRestoreFlow")
}
