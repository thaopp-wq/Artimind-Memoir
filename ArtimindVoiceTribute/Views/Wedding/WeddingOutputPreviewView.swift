import SwiftUI
import UIKit
import Photos

struct WeddingOutputPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = WeddingTributeManager.shared
    @State private var isPlaying = false
    @State private var isMuted = false
    @State private var isLiked = false
    @State private var showShareSheet = false
    @State private var toastMessage: String?

    private var template: WeddingTemplate? { manager.selectedTemplate }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(
                    title: "A Moment Together",
                    onBack: { handleBackToMoments() },
                    trailingButton: AnyView(
                        HStack(spacing: 8) {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                    isLiked.toggle()
                                }
                            } label: {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(isLiked ? Color(hex: "#FF4D6A") : .primary)
                                    .scaleEffect(isLiked ? 1.15 : 1.0)
                                    .frame(width: 44, height: 44)
                                    .glassBackground(shape: .circle, interactive: true)
                            }
                            .buttonStyle(.plain)

                            GlassCircleButton(icon: "arrow.down.to.line", action: handleSave)
                        }
                    )
                )
                .padding(.top, 8)

                Spacer(minLength: 4)

                videoPlayer
                    .padding(.horizontal, 0)

                playbackControls
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                actionButtons
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 14)
            }

            if let toast = toastMessage {
                toastView(toast)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showShareSheet) {
            WeddingShareSheet(items: shareItems())
        }
    }

    // MARK: - Video Player (full-bleed)

    private var videoPlayer: some View {
        ZStack {
            GeometryReader { proxy in
                ZStack {
                    if let imageName = template?.thumbnail, !imageName.isEmpty {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                    } else {
                        LinearGradient(
                            colors: [Color(hex: "#4E4E4E"), Color(hex: "#242424"), Color(hex: "#0F0F0F")],
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

            // Play/Pause button
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
        .aspectRatio(9.0 / 16.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Playback Controls

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

            HStack(spacing: 8) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColor.tabActive)
                Text("Full screen")
                    .font(AppFont.dmSans(.regular, size: 13))
                    .foregroundColor(.white)
            }

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

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Share button (main, wide)
            LiquidGlassTextButton(
                title: "Share",
                icon: "square.and.arrow.up",
                font: AppFont.dmSans(.semibold, size: 16),
                foregroundColor: .white,
                shape: .capsule,
                action: handleShare
            )

            // Recreate button (circle)
            Button {
                handleBackToMoments()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .glassBackground(shape: .circle, interactive: true)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Toast

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

    // MARK: - Actions

    private func handleSave() {
        guard let imageName = template?.thumbnail,
              let image = UIImage(named: imageName) else {
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

    private func handleBackToMoments() {
        manager.cancelProcessing()
        NotificationCenter.default.post(name: .popWeddingFlow, object: nil)
    }

    private func shareItems() -> [Any] {
        var items: [Any] = []
        if let imageName = template?.thumbnail,
           let image = UIImage(named: imageName) {
            items.append(image)
        }
        items.append("Made with Artimind")
        return items
    }

    private func flashToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) { toastMessage = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.25)) { toastMessage = nil }
        }
    }
}

// MARK: - Share Sheet

private struct WeddingShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        WeddingOutputPreviewView()
            .onAppear {
                WeddingTributeManager.shared.selectTemplate(WeddingTemplate.samples[0])
            }
    }
    .preferredColorScheme(.dark)
}
