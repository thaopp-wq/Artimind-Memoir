import SwiftUI
import UIKit
import Photos

struct ResultView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false
    @State private var isMuted = false
    @State private var showFullScreen = false
    @State private var showShareSheet = false
    @State private var downloadToast: String?

    private var theme: AlbumThemeSpec? { GenerationManager.shared.selectedTheme }
    private var aspectRatio: CGFloat { theme?.aspectRatio ?? (9.0 / 16.0) }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(
                    title: "Result",
                    onBack: { dismiss() },
                    trailingButton: AnyView(
                        GlassCircleButton(icon: "arrow.down.to.line", action: handleDownload)
                    )
                )
                .padding(.top, 8)

                Spacer(minLength: 12)

                videoPlayer
                    .padding(.horizontal, 16)

                Spacer(minLength: 16)

                playbackControls
                    .padding(.horizontal, 16)

                actionButtons
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 14)
            }

            if let toast = downloadToast {
                toastView(toast)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenResultView(
                isPresented: $showFullScreen,
                onRetry: handleTryNewTheme,
                onDownload: handleDownload,
                onShare: handleShare
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems())
        }
    }

    private var videoPlayer: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack {
                    if let imageName = theme?.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                    } else {
                        LinearGradient(
                            colors: theme?.gradientColors ?? [
                                Color(hex: "#4E4E4E"),
                                Color(hex: "#242424"),
                                Color(hex: "#0F0F0F")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }

                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.18)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    isPlaying.toggle()
                }
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundColor(.white)
                    .offset(x: isPlaying ? 0 : 2)
                    .frame(width: 58, height: 58)
                    .glassBackground(shape: .circle, interactive: true)
            }
            .buttonStyle(.plain)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }

    private func resultPortrait(colors: [Color], xOffset: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)

            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 92)
                .offset(y: -104)

            HStack(spacing: 20) {
                personSilhouette(scale: 0.95)
                personSilhouette(scale: 0.78)
            }
            .offset(x: xOffset, y: 14)
        }
        .saturation(0)
    }

    private func personSilhouette(scale: CGFloat) -> some View {
        VStack(spacing: -8) {
            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: 44 * scale, height: 44 * scale)

            Ellipse()
                .fill(Color.white.opacity(0.20))
                .frame(width: 70 * scale, height: 108 * scale)
        }
    }

    private var playbackControls: some View {
        HStack(alignment: .center, spacing: 0) {
            Button {} label: {
                Image(systemName: "flag.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
                    .glassBackground(shape: .circle, interactive: true)
            }

            Spacer()

            Button {
                showFullScreen = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColor.tabActive)
                    Text("Full screen")
                        .font(AppFont.dmSans(.regular, size: 13))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                isMuted.toggle()
            } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
                    .glassBackground(shape: .circle, interactive: true)
            }
        }
        .frame(height: 44)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            LiquidGlassTextButton(
                title: "Share",
                icon: "square.and.arrow.up",
                font: AppFont.dmSans(.semibold, size: 16),
                foregroundColor: .white,
                shape: .capsule,
                action: handleShare
            )

            Button {
                handleTryNewTheme()
            } label: {
                Text("Try a new theme")
                    .font(AppFont.dmSans(.bold, size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Capsule().fill(Color.white))
            }
            .buttonStyle(.plain)
        }
    }

    private func toastView(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(AppFont.dmSans(.medium, size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.black.opacity(0.85)))
                .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                .padding(.bottom, 130)
        }
        .transition(.opacity)
    }

    // MARK: Actions

    private func handleDownload() {
        guard let image = renderResultImage() else {
            flashToast("Nothing to save yet")
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    flashToast("Photos access denied")
                    return
                }
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, _ in
                    DispatchQueue.main.async {
                        flashToast(success ? "Saved to Photos" : "Save failed")
                    }
                }
            }
        }
    }

    private func handleShare() {
        showShareSheet = true
    }

    /// "Try a new theme": cancel any background generation and send the user back to the theme list.
    private func handleTryNewTheme() {
        GenerationManager.shared.cancel()
        showFullScreen = false
        NotificationCenter.default.post(name: .popGenerationFlow, object: nil)
    }

    private func shareItems() -> [Any] {
        var items: [Any] = []
        if let image = renderResultImage() { items.append(image) }
        items.append("Made with Artimind ✨")
        return items
    }

    /// Until a real video is generated, fall back to the theme's hero image as the shareable / saveable artifact.
    private func renderResultImage() -> UIImage? {
        if let name = theme?.imageName, let img = UIImage(named: name) {
            return img
        }
        return nil
    }

    private func flashToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) { downloadToast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.25)) { downloadToast = nil }
        }
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Full Screen Landscape Variant

struct FullScreenResultView: View {
    @Binding var isPresented: Bool
    let onRetry: () -> Void
    let onDownload: () -> Void
    let onShare: () -> Void

    @State private var progress: CGFloat = 0.18
    @State private var showOverlay = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { proxy in
                HStack(spacing: 0) {
                    landscapePortrait(colors: [Color(hex: "#3B3B3B"), Color(hex: "#1B1B1B"), Color(hex: "#0A0A0A")])
                    landscapePortrait(colors: [Color(hex: "#9E9E9E"), Color(hex: "#4A4A4A"), Color(hex: "#0E0E0E")])
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .saturation(0)
            }
            .ignoresSafeArea()

            if showOverlay {
                overlayLayer
            }
        }
        .statusBarHidden(true)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.18)) { showOverlay.toggle() }
        }
    }

    private var overlayLayer: some View {
        ZStack {
            // Top gradient for top buttons
            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.black.opacity(0)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Bottom gradient for caption + progress bar
            LinearGradient(
                colors: [Color.black.opacity(0), Color.black.opacity(0.55), Color.black.opacity(0.9)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                topBar
                Spacer()
                bottomBar
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
        }
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            GlassBackButton(action: { isPresented = false })

            Spacer()

            HStack(spacing: 12) {
                circleButton(icon: "arrow.down.to.line", action: onDownload)
                circleButton(icon: "arrow.clockwise", action: {
                    isPresented = false
                    onRetry()
                })
                circleButton(icon: "arrowshape.turn.up.right.fill", action: onShare)
            }
        }
    }

    private func circleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.black.opacity(0.35)))
                .glassBackground(
                    shape: .circle,
                    enableBorder: true,
                    borderColor: Color.white.opacity(0.22),
                    borderLineWidth: 1,
                    interactive: true
                )
        }
        .buttonStyle(.plain)
    }

    private var bottomBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#FF4D4D"))
                Text("Full screen")
                    .font(AppFont.dmSans(.regular, size: 13))
                    .foregroundColor(.white)
            }

            HStack(alignment: .firstTextBaseline) {
                Text("Fire of the Brave 🔥🥹")
                    .font(AppFont.dmSans(.semibold, size: 19))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                Text("00:18 / 00:21")
                    .font(AppFont.dmSans(.regular, size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .monospacedDigit()
            }

            progressBar
                .padding(.top, 2)
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.28))
                    .frame(height: 3)

                Capsule()
                    .fill(Color.white)
                    .frame(width: proxy.size.width * progress, height: 3)
            }
        }
        .frame(height: 3)
    }

    private func landscapePortrait(colors: [Color]) -> some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        ResultView()
    }
    .preferredColorScheme(.dark)
}
