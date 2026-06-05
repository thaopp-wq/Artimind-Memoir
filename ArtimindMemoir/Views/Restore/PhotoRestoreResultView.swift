import SwiftUI
import Photos

struct PhotoRestoreResultView: View {
    let originalImage: UIImage
    let restoredImage: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var isHoldingCompare = false
    @State private var showFullScreen = false
    @State private var isFlagged = false
    @State private var toastMessage: String?

    private var displayImage: UIImage {
        isHoldingCompare ? originalImage : restoredImage
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar — solid dark controls (§6.6)
                ZStack {
                    Text("Result")
                        .font(AppFont.cormorant(.semibold, size: 21))
                        .foregroundStyle(ArtimindDS.ColorToken.textPrimary)

                    HStack {
                        Button {
                            NotificationCenter.default.post(name: .popRestoreFlow, object: nil)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.black.opacity(0.62)))
                                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        }
                        Spacer()
                        Button { savePhoto() } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.black.opacity(0.62)))
                                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .frame(height: 54)
                .padding(.top, ArtimindDS.Spacing.xs)

                // Photo with overlay controls
                ZStack(alignment: .bottom) {
                    Image(uiImage: displayImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous))
                        .padding(.horizontal, ArtimindDS.Spacing.xs)
                        .animation(.easeInOut(duration: 0.15), value: isHoldingCompare)
                        .contentShape(Rectangle())
                        .gesture(
                            LongPressGesture(minimumDuration: 0.15)
                                .onChanged { _ in isHoldingCompare = true }
                                .sequenced(before: DragGesture(minimumDistance: 0))
                                .onEnded { _ in isHoldingCompare = false }
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { _ in isHoldingCompare = false }
                        )

                    // Before label (hold to compare)
                    if isHoldingCompare {
                        Text("BEFORE")
                            .font(AppFont.dmSans(.bold, size: 11))
                            .foregroundStyle(.white)
                            .padding(.horizontal, ArtimindDS.Spacing.sm)
                            .padding(.vertical, ArtimindDS.Spacing.xxs)
                            .background(Capsule().fill(Color.black.opacity(0.62)))
                            .padding(.bottom, 56)
                    }
                }
                .padding(.vertical, ArtimindDS.Spacing.xs)

                // Bottom buttons (§6.3 white pill + §6.4 outlined)
                HStack(spacing: ArtimindDS.Spacing.sm) {
                    Button { showShareSheet = true } label: {
                        Text("Share")
                            .font(ArtimindDS.Typography.button)
                            .foregroundStyle(ArtimindDS.ColorToken.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                Capsule().fill(ArtimindDS.ColorToken.panel)
                            )
                            .overlay(
                                Capsule().stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {} label: {
                        Text("Create Video")
                            .font(ArtimindDS.Typography.button)
                            .foregroundStyle(ArtimindDS.ColorToken.blackText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                Capsule().fill(ArtimindDS.ColorToken.whiteButton)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.bottom, ArtimindDS.Spacing.xl)
            }

            // Toast
            if let toast = toastMessage {
                VStack {
                    HStack(spacing: ArtimindDS.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(ArtimindDS.ColorToken.sage)
                        Text(toast)
                            .font(ArtimindDS.Typography.body)
                            .foregroundStyle(ArtimindDS.ColorToken.textPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(ArtimindDS.ColorToken.panel))
                    .padding(.top, 70)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [restoredImage, "Made with Artimind"])
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            LandscapePhotoViewer(image: restoredImage)
        }
    }

    // MARK: - Save

    private func savePhoto() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    flashToast("Photos access denied")
                    return
                }
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: restoredImage)
                } completionHandler: { success, _ in
                    DispatchQueue.main.async {
                        flashToast(success ? "Saved to Photos" : "Save failed")
                    }
                }
            }
        }
    }

    private func flashToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) { toastMessage = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.25)) { toastMessage = nil }
        }
    }
}

// MARK: - Landscape Photo Viewer

private struct LandscapePhotoViewer: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .rotationEffect(.degrees(90))

            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.black.opacity(0.62)))
                            .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                    }
                    Spacer()
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, ArtimindDS.Spacing.sm)
                Spacer()
            }
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        PhotoRestoreResultView(
            originalImage: UIImage(named: "hero-memory")!,
            restoredImage: UIImage(named: "hero-memory")!
        )
    }
    .preferredColorScheme(.dark)
}
