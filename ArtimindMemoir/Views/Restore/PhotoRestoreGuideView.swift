import SwiftUI

struct PhotoRestoreGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var navigateToPreview = false
    @State private var navigateToProcessing = false

    var preselectedImageName: String?

    private var hasPreselected: Bool { preselectedImageName != nil }

    private let goodPhotos = ["avatar-man", "avatar-woman", "hero-memory", "explore-restore"]
    private let badPhotos = ["explore-loved-ones", "explore-living-album", "wedding-preview", "icon-mascot"]

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Photo Restoration Guide", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // Good photos
                    goodPhotosSection

                    // Bad photos
                    badPhotosSection
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }

            // CTA buttons
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
            if selectedImage != nil {
                navigateToPreview = true
            }
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

    // MARK: - Good photos

    private var goodPhotosSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Good photos")
                .font(AppFont.dmSans(.bold, size: 22))
                .foregroundStyle(.white)

            Text("Old paper photos, clearly scanned, old family photos with clear faces,\u{2003}black and white photos, film photos")
                .font(AppFont.dmSans(.regular, size: 13))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .lineSpacing(3)

            photoGrid(images: goodPhotos, isGood: true)
                .padding(.top, 6)
        }
    }

    // MARK: - Bad photos

    private var badPhotosSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bad photos")
                .font(AppFont.dmSans(.bold, size: 22))
                .foregroundStyle(.white)

            Text("AI Restore is for refreshing damaged photos, not for \u{201C}beautifying\u{201D}\u{2003}new photos")
                .font(AppFont.dmSans(.regular, size: 13))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .lineSpacing(3)

            photoGrid(images: badPhotos, isGood: false)
                .padding(.top, 6)
        }
    }

    // MARK: - Photo grid with badges

    private func photoGrid(images: [String], isGood: Bool) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
        ]

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(images, id: \.self) { img in
                ZStack(alignment: .topLeading) {
                    Image(img)
                        .resizable()
                        .scaledToFill()
                        .frame(minHeight: 90)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    // Badge
                    Image(systemName: isGood ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(isGood ? .green : .red)
                        .offset(x: 4, y: 4)
                }
            }
        }
    }

    // MARK: - CTA buttons

    private var ctaButtons: some View {
        VStack(spacing: 10) {
            if hasPreselected {
                Button { navigateToProcessing = true } label: {
                    Text("Continue")
                        .font(AppFont.dmSans(.bold, size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Capsule().fill(AppColor.brandMain)
                        )
                }
                .buttonStyle(.plain)
            } else {
                Button { showPicker = true } label: {
                    Text("Photo Library")
                        .font(AppFont.dmSans(.bold, size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Capsule().fill(AppColor.brandMain)
                        )
                }
                .buttonStyle(.plain)

                Button { showCamera = true } label: {
                    Text("Camera")
                        .font(AppFont.dmSans(.bold, size: 16))
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
            }
        }
        .padding(.horizontal, ArtimindDS.Size.sidePadding)
        .padding(.bottom, 36)
    }
}

// MARK: - ImagePicker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - CameraPicker

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        PhotoRestoreGuideView()
    }
    .preferredColorScheme(.dark)
}
