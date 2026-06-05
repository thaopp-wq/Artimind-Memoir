import SwiftUI

struct VideoRestoreGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var navigateToPreview = false
    @State private var navigateToProcessing = false

    var preselectedImageName: String?

    private let goodPhotos = ["avatar-man", "avatar-woman", "hero-memory", "explore-loved-ones"]
    private let badPhotos = ["explore-living-album", "icon-mascot", "wedding-preview", "explore-restore"]

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Video Restore Guide", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    photoSection(
                        title: "Good photos",
                        description: "Clear portraits, family group photos, landscapes with people, photos with expressive faces",
                        images: goodPhotos,
                        isGood: true
                    )

                    photoSection(
                        title: "Bad photos",
                        description: "Abstract art, heavily cropped images, text-only photos, screenshots or documents",
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
        VideoRestoreGuideView()
    }
    .preferredColorScheme(.dark)
}
