import SwiftUI
import PhotosUI

struct WeddingUploadPhotosView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = WeddingTributeManager.shared
    @State private var navigateToAudio = false
    @State private var multiPickerSelections: [PhotosPickerItem] = []
    @State private var pickerSlotIndex: Int = 0

    private var template: WeddingTemplate? { manager.selectedTemplate }

    /// Number of empty slots from the tapped slot onward.
    private func emptySlotCount(from index: Int) -> Int {
        guard index < manager.photos.count else { return 0 }
        return manager.photos[index...].filter { $0 == nil }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Uploading Images", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    photoSlots
                }
                .padding(.bottom, 100)
            }

            continueButton
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $navigateToAudio) {
            WeddingUploadAudioView()
        }
        .onChange(of: multiPickerSelections) { _, newItems in
            guard !newItems.isEmpty else { return }
            loadMultiplePhotos(newItems, from: pickerSlotIndex)
            multiPickerSelections = []
        }
    }

    // MARK: - Photo Slots

    private var photoSlots: some View {
        let labels = template?.photoLabels ?? []

        return VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<manager.photos.count, id: \.self) { index in
                let label = index < labels.count ? labels[index] : "Photo \(index + 1)"
                photoSlotSection(index: index, label: label)
            }
        }
    }

    @ViewBuilder
    private func photoSlotSection(index: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                Text(label)
                    .font(AppFont.dmSans(.bold, size: 16))
                    .foregroundColor(.white)
            }
            .padding(.top, 16)

            if let img = manager.photos[index] {
                filledSlot(index: index, image: img)
            } else {
                emptySlotPicker(index: index)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Empty Slot (multi-select picker)

    private func emptySlotPicker(index: Int) -> some View {
        PhotosPicker(
            selection: $multiPickerSelections,
            maxSelectionCount: emptySlotCount(from: index),
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#2A2A2C"))
                    .frame(width: 220, height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                            )
                            .foregroundColor(Color.white.opacity(0.12))
                    )
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.5))
                    )

                Circle()
                    .fill(Color(hex: "#E8C840"))
                    .frame(width: 22, height: 22)
                    .overlay(
                        Text("i")
                            .font(.system(size: 13, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                    )
                    .offset(x: 4, y: -4)
            }
        }
        .buttonStyle(.plain)
        .onTapGesture {} // capture slot index before picker opens
        .onAppear {} // no-op
        .simultaneousGesture(TapGesture().onEnded { pickerSlotIndex = index })
    }

    // MARK: - Filled Slot

    private func filledSlot(index: Int, image: UIImage) -> some View {
        let warning = index < manager.photoWarnings.count ? manager.photoWarnings[index] : nil

        return VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        manager.removePhoto(at: index)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 28, height: 28)
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .offset(x: 6, y: 6)
            }

            if let warning {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 11, weight: .medium))
                    Text(warning)
                        .font(AppFont.dmSans(.regular, size: 11))
                }
                .foregroundColor(Color(hex: "#E8C840"))
                .lineLimit(2)
            }
        }
    }

    // MARK: - Load Multiple Photos

    private func loadMultiplePhotos(_ items: [PhotosPickerItem], from startIndex: Int) {
        let emptyIndices = manager.photos.indices.filter { $0 >= startIndex && manager.photos[$0] == nil }

        for (i, item) in items.enumerated() {
            guard i < emptyIndices.count else { break }
            let slotIndex = emptyIndices[i]
            item.loadTransferable(type: Data.self) { result in
                Task { @MainActor in
                    if case .success(let data) = result,
                       let data, let uiImage = UIImage(data: data) {
                        manager.setPhoto(uiImage, at: slotIndex)
                    }
                }
            }
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Button {
            navigateToAudio = true
        } label: {
            Text("Continue")
                .font(AppFont.dmSans(.bold, size: 17))
                .foregroundColor(manager.canContinuePhotos ? .white : Color(hex: "#6B6B6E"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Capsule().fill(
                        manager.canContinuePhotos
                            ? Color(hex: "#8E0612")
                            : Color(hex: "#2A2A2C")
                    )
                )
        }
        .disabled(!manager.canContinuePhotos)
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }
}

#Preview {
    NavigationStack {
        WeddingUploadPhotosView()
            .onAppear {
                WeddingTributeManager.shared.selectTemplate(WeddingTemplate.samples[0])
            }
    }
    .preferredColorScheme(.dark)
}
