import ActivityKit
import WidgetKit
import SwiftUI

private let brandRed = Color(red: 0.65, green: 0.04, blue: 0.09)
private let cardBlack = Color(red: 0.04, green: 0.04, blue: 0.05)
private let progressTrack = Color(red: 0.94, green: 0.93, blue: 0.91)
private let progressFill = Color(red: 0.94, green: 0.93, blue: 0.91)
private let dotRed = Color(red: 0.90, green: 0.18, blue: 0.20)
private let successGreen = Color(red: 0.20, green: 0.78, blue: 0.35)
private let subtitleGray = Color.white.opacity(0.55)

@available(iOS 16.2, *)
struct ArtimindGeneratingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ArtimindActivityAttributes.self) { context in
            LockScreenView(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    butterflyTile(size: 32)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    trailingDI(state: context.state)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(centerText(for: context.state))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(1)
                }
            } compactLeading: {
                butterflyTile(size: 20)
                    .padding(.leading, 2)
            } compactTrailing: {
                trailingCompact(state: context.state)
            } minimal: {
                Image(systemName: "sparkles")
                    .foregroundStyle(brandRed)
            }
        }
    }

    private func centerText(for state: ArtimindActivityAttributes.ContentState) -> String {
        switch state.phase {
        case .generating: return state.remainingText
        case .ready:      return "Tap to view"
        case .failed:     return "Try again"
        }
    }

    @ViewBuilder
    private func trailingDI(state: ArtimindActivityAttributes.ContentState) -> some View {
        switch state.phase {
        case .generating:
            Text(state.remainingText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .monospacedDigit()
        case .ready:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(successGreen)
        case .failed:
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.orange)
        }
    }

    @ViewBuilder
    private func trailingCompact(state: ArtimindActivityAttributes.ContentState) -> some View {
        switch state.phase {
        case .generating:
            Text(state.remainingText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .monospacedDigit()
                .padding(.trailing, 4)
        case .ready:
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(successGreen)
                .padding(.trailing, 4)
        case .failed:
            Image(systemName: "exclamationmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.orange)
                .padding(.trailing, 4)
        }
    }
}

@available(iOS 16.2, *)
private func butterflyTile(size: CGFloat) -> some View {
    Image("butterfly-red")
        .resizable()
        .scaledToFit()
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
}

@available(iOS 16.2, *)
struct LockScreenView: View {
    let context: ActivityViewContext<ArtimindActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                Image("butterfly-red")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(subtitleGray)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                trailingAccessory
            }

            if context.state.phase != .failed {
                progressBar
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    private var title: String {
        switch context.state.phase {
        case .generating: return "We are generating your album..."
        case .ready:      return "Your Living Album is ready"
        case .failed:     return "Something went wrong"
        }
    }

    private var subtitle: String {
        switch context.state.phase {
        case .generating: return "Ready in: \(context.state.remainingText)"
        case .ready:      return "Tap to watch your memories come to life"
        case .failed:     return "Your video wasn't created. Please try again"
        }
    }

    @ViewBuilder
    private var trailingAccessory: some View {
        switch context.state.phase {
        case .generating, .failed:
            Image("album-thumb")
                .resizable()
                .scaledToFill()
                .frame(width: 58, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        case .ready:
            ZStack {
                Circle()
                    .stroke(successGreen, lineWidth: 2.5)
                    .frame(width: 38, height: 38)
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(successGreen)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            let p = max(0.02, min(1, context.state.progress))
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(progressTrack.opacity(0.18))
                    .frame(height: 4)

                Capsule()
                    .fill(progressFill)
                    .frame(width: proxy.size.width * p, height: 4)

                Circle()
                    .fill(dotRed)
                    .frame(width: 8, height: 8)
                    .offset(x: max(0, proxy.size.width * p - 4))
            }
        }
        .frame(height: 8)
    }
}
