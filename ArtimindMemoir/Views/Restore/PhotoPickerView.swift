import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    let title: String
    let subtitle: String
    let onImageSelected: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showLibrary = false
    @State private var showCamera = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: title, onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero text
                    VStack(spacing: 8) {
                        Text(subtitle)
                            .font(AppFont.dmSans(.regular, size: 14))
                            .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Photo slot
                    photoSlot

                    // Source buttons (if no photo)
                    if selectedImage == nil {
                        sourceButtons
                    }
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }

            // Continue button
            Button {
                if let img = selectedImage {
                    onImageSelected(img)
                }
            } label: {
                Text("Continue")
                    .font(AppFont.dmSans(.bold, size: 16))
                    .foregroundStyle(selectedImage != nil ? .black : AppColor.disabledButtonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule().fill(selectedImage != nil ? Color.white : AppColor.disabledButton)
                    )
            }
            .buttonStyle(.plain)
            .disabled(selectedImage == nil)
            .padding(.horizontal, ArtimindDS.Size.sidePadding)
            .padding(.bottom, 32)
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
                        selectedImage = img
                    }
                    pickerItem = nil
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $selectedImage)
        }
    }

    // MARK: - Photo Slot

    private var photoSlot: some View {
        Group {
            if let photo = selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous))

                    Button { selectedImage = nil } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white, Color.black.opacity(0.6))
                    }
                    .padding(12)

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
                VStack(spacing: 14) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 44))
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)

                    Text("Select a photo to get started")
                        .font(AppFont.dmSans(.medium, size: 14))
                        .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
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
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Library")
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
            .buttonStyle(.plain)

            Button { showCamera = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Camera")
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
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        PhotoPickerView(title: "Choose Photo", subtitle: "Select a photo to restore") { _ in }
    }
    .preferredColorScheme(.dark)
}
