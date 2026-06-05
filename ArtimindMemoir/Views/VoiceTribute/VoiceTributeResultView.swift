import SwiftUI

struct VoiceTributeResultView: View {
    @ObservedObject private var session = VoiceTributeSession.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false
    @State private var isLiked = false
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar — solid dark controls
                ZStack {
                    Text("A Moment Together")
                        .font(AppFont.cormorant(.semibold, size: 21))
                        .foregroundStyle(.white)

                    HStack(spacing: 8) {
                        // Back
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.black.opacity(0.62)))
                                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        }

                        Spacer()

                        // Heart
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                isLiked.toggle()
                            }
                        } label: {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(isLiked ? Color(hex: "#FF4D6A") : .white)
                                .scaleEffect(isLiked ? 1.15 : 1.0)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.black.opacity(0.62)))
                                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        }

                        // Download
                        Button {} label: {
                            Image(systemName: "arrow.down.to.line")
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

                // Video preview
                ZStack {
                    if let photo = session.photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Placeholder
                        RoundedRectangle(cornerRadius: 0)
                            .fill(ArtimindDS.ColorToken.panel)
                            .overlay(
                                Image(systemName: "play.rectangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                            )
                    }

                    // Play button
                    Button { isPlaying.toggle() } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 54))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.4), radius: 8, y: 2)
                    }
                    .buttonStyle(.plain)

                    // Veo badge bottom-right
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Veo")
                                .font(AppFont.dmSans(.medium, size: 11))
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(8)
                        }
                    }
                }

                // Controls row
                HStack {
                    // Flag
                    Image(systemName: "flag")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                        .frame(width: 32, height: 32)

                    Spacer()

                    // Full screen
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Full screen")
                            .font(AppFont.dmSans(.medium, size: 12))
                    }
                    .foregroundStyle(ArtimindDS.ColorToken.textSecondary)

                    Spacer()

                    // Play indicator
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.15)))
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.vertical, ArtimindDS.Spacing.xs)

                Spacer()

                // Share button
                Button { showShareSheet = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share")
                            .font(AppFont.dmSans(.semibold, size: 16))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule().fill(ArtimindDS.ColorToken.panel)
                    )
                    .overlay(
                        Capsule().stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.bottom, ArtimindDS.Spacing.xl)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showShareSheet) {
            TributeShareSheet(items: ["Made with Artimind"])
        }
    }
}

private struct TributeShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        VoiceTributeResultView()
    }
    .preferredColorScheme(.dark)
}
