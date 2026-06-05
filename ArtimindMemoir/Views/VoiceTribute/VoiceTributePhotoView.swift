import SwiftUI
import PhotosUI
import Vision

struct VoiceTributePhotoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var session = VoiceTributeSession.shared
    @State private var navigateToAudio = false
    @State private var showLibrary = false
    @State private var showCamera = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var faceWarning: String?
    @State private var isDetecting = false

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Choose Photo", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero text
                    VStack(spacing: 8) {
                        (
                            Text("Choose a face\nto ")
                                .font(AppFont.cormorant(.bold, size: 28))
                                .foregroundColor(.white)
                            +
                            Text("bring back.")
                                .font(AppFont.cormorant(.regular, size: 28).italic())
                                .foregroundColor(ArtimindDS.ColorToken.textSecondary)
                        )
                        .multilineTextAlignment(.center)
                    }

                    // Photo slot
                    photoSlot

                    // Face warning
                    if let warning = faceWarning {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(ArtimindDS.ColorToken.yellow)
                            Text(warning)
                                .font(AppFont.dmSans(.regular, size: 13))
                                .foregroundStyle(ArtimindDS.ColorToken.yellow)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                                .fill(ArtimindDS.ColorToken.yellowDark.opacity(0.5))
                        )
                    }

                    // Source buttons (if no photo yet)
                    if session.photo == nil {
                        sourceButtons
                    }

                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }

            // Continue button
            continueButton
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .photosPicker(isPresented: $showLibrary, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) {
            guard let item = pickerItem else { return }
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    if case .success(let data) = result, let data, let img = UIImage(data: data) {
                        session.photo = img
                        detectFace(in: img)
                    }
                    pickerItem = nil
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: Binding(
                get: { session.photo },
                set: { img in
                    session.photo = img
                    if let img { detectFace(in: img) }
                }
            ))
        }
        .navigationDestination(isPresented: $navigateToAudio) {
            VoiceTributeAudioView()
        }
    }

    // MARK: - Photo Slot

    private var photoSlot: some View {
        Group {
            if isDetecting {
                // Detecting state
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(ArtimindDS.ColorToken.yellow)
                    Text("Detecting face...")
                        .font(AppFont.dmSans(.medium, size: 14))
                        .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .background(
                    RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                        .fill(ArtimindDS.ColorToken.panel)
                )
            } else if let photo = session.photo {
                // Photo loaded
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous))

                    // Remove button
                    Button {
                        session.photo = nil
                        faceWarning = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white, Color.black.opacity(0.6))
                    }
                    .padding(12)

                    // Replace button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button { showLibrary = true } label: {
                                Text("Replace")
                                    .font(AppFont.dmSans(.medium, size: 13))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(Capsule().fill(Color.black.opacity(0.6)))
                            }
                        }
                        .padding(12)
                    }
                }
            } else {
                // Empty state
                VStack(spacing: 14) {
                    Image(systemName: "person.crop.rectangle.badge.plus")
                        .font(.system(size: 44))
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)

                    Text("Select a clear portrait photo")
                        .font(AppFont.dmSans(.medium, size: 14))
                        .foregroundStyle(ArtimindDS.ColorToken.textSecondary)

                    Text("Face should be visible and well-lit")
                        .font(AppFont.dmSans(.regular, size: 12))
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(
                    RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                        .strokeBorder(
                            ArtimindDS.ColorToken.stroke,
                            style: StrokeStyle(lineWidth: 1, dash: [8, 5])
                        )
                )
                .onTapGesture { showLibrary = true }
            }
        }
    }

    // MARK: - Source Buttons

    private var sourceButtons: some View {
        HStack(spacing: 10) {
            Button { showLibrary = true } label: {
                sourceButton(icon: "photo.on.rectangle", title: "Library")
            }
            .buttonStyle(.plain)

            Button { showCamera = true } label: {
                sourceButton(icon: "camera", title: "Camera")
            }
            .buttonStyle(.plain)
        }
    }

    private func sourceButton(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(AppFont.dmSans(.semibold, size: 14))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button { navigateToAudio = true } label: {
            Text("Continue")
                .font(AppFont.dmSans(.bold, size: 16))
                .foregroundStyle(session.hasPhoto ? .black : AppColor.disabledButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Capsule().fill(session.hasPhoto ? Color.white : AppColor.disabledButton)
                )
        }
        .buttonStyle(.plain)
        .disabled(!session.hasPhoto)
        .padding(.horizontal, ArtimindDS.Size.sidePadding)
        .padding(.bottom, 32)
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Photo tips")
                .font(AppFont.dmSans(.semibold, size: 14))
                .foregroundStyle(.white)

            tipRow(icon: "face.smiling", text: "Clear, front-facing portrait works best")
            tipRow(icon: "light.max", text: "Good lighting, no heavy shadows")
            tipRow(icon: "person.fill", text: "Only one person in the photo")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(ArtimindDS.ColorToken.yellow)
                .frame(width: 20)
            Text(text)
                .font(AppFont.dmSans(.regular, size: 12))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
        }
    }

    // MARK: - Face Detection (non-blocking)

    private func detectFace(in image: UIImage) {
        isDetecting = true
        faceWarning = nil

        DispatchQueue.global(qos: .userInitiated).async {
            guard let cgImage = image.cgImage else {
                DispatchQueue.main.async {
                    isDetecting = false
                    faceWarning = "Could not process this image. You can still continue."
                }
                return
            }

            let request = VNDetectFaceRectanglesRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
                let faces = request.results ?? []

                DispatchQueue.main.async {
                    isDetecting = false
                    if faces.isEmpty {
                        faceWarning = "No face detected. For best results, use a clear portrait photo."
                    } else if faces.count > 1 {
                        faceWarning = "Multiple faces detected. Results work best with a single face."
                    } else {
                        let face = faces[0]
                        if face.boundingBox.width < 0.15 || face.boundingBox.height < 0.15 {
                            faceWarning = "Face appears too small. Try a closer portrait photo."
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isDetecting = false
                    faceWarning = "Face detection failed. You can still continue."
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VoiceTributePhotoView()
    }
    .preferredColorScheme(.dark)
}
