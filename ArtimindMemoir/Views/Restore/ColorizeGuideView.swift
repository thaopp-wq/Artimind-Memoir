import SwiftUI

struct ColorizeGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var navigateToPreview = false
    @State private var navigateToProcessing = false

    var preselectedImageName: String?

    private let goodPhotos = ["avatar-man", "hero-memory", "explore-restore", "avatar-woman"]
    private let badPhotos = ["explore-loved-ones", "explore-living-album", "wedding-preview", "icon-mascot"]

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Colorize Guide", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // Good photos
                    photoSection(
                        title: "Good photos",
                        description: "Black-and-white portraits, old family photos, film scans, faded sepia prints",
                        images: goodPhotos,
                        isGood: true
                    )

                    // Bad photos
                    photoSection(
                        title: "Bad photos",
                        description: "Already colored photos, drawings or paintings, extremely dark or overexposed images",
                        images: badPhotos,
                        isGood: false
                    )
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }

            ctaButtons
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $selectedImage)
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) {
            if selectedImage != nil { navigateToPreview = true }
        }
        .navigationDestination(isPresented: $navigateToPreview) {
            if let img = selectedImage {
                PhotoRestorePreviewView(image: img)
            }
        }
        .navigationDestination(isPresented: $navigateToProcessing) {
            if let name = preselectedImageName, let img = UIImage(named: name) {
                PhotoRestoreProcessingView(image: img)
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "paintbrush")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(ArtimindDS.ColorToken.yellow)

            Text("AI Colorize")
                .font(AppFont.cormorant(.bold, size: 28))
                .foregroundStyle(.white)

            Text("Breathe new life into black-and-white photos. Our AI adds natural, realistic color to every detail.")
                .font(AppFont.dmSans(.regular, size: 14))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    // MARK: - Photo section

    private func photoSection(title: String, description: String, images: [String], isGood: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.dmSans(.bold, size: 22))
                .foregroundStyle(.white)

            Text(description)
                .font(AppFont.dmSans(.regular, size: 13))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .lineSpacing(3)

            let columns = [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
            ]

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(images, id: \.self) { img in
                    ZStack(alignment: .topLeading) {
                        Image(img)
                            .resizable()
                            .scaledToFill()
                            .frame(minHeight: 90)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .saturation(isGood ? 0 : 1) // B&W for good photos

                        Image(systemName: isGood ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(isGood ? .green : .red)
                            .offset(x: 4, y: 4)
                    }
                }
            }
            .padding(.top, 6)
        }
    }

    // MARK: - CTA

    private var ctaButtons: some View {
        VStack(spacing: 10) {
            if preselectedImageName != nil {
                Button { navigateToProcessing = true } label: {
                    Text("Continue")
                        .font(AppFont.dmSans(.bold, size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Capsule().fill(AppColor.brandMain))
                }
                .buttonStyle(.plain)
            } else {
                Button { showPicker = true } label: {
                    Text("Photo Library")
                        .font(AppFont.dmSans(.bold, size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Capsule().fill(AppColor.brandMain))
                }
                .buttonStyle(.plain)

                Button { showCamera = true } label: {
                    Text("Camera")
                        .font(AppFont.dmSans(.bold, size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Capsule().fill(ArtimindDS.ColorToken.panel))
                        .overlay(Capsule().stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, ArtimindDS.Size.sidePadding)
        .padding(.bottom, 36)
    }
}

#Preview {
    NavigationStack {
        ColorizeGuideView()
    }
    .preferredColorScheme(.dark)
}
