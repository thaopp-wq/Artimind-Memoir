import SwiftUI

struct TextEditResultView: View {
    let originalImage: UIImage
    let editedImage: UIImage
    let editCount: Int
    let maxEdits: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showSavedToast = false
    @State private var isHoldingCompare = false
    @State private var navigateToEdit = false
    @State private var navigateToStartOver = false

    private var canEditMore: Bool { editCount < maxEdits }

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(
                title: "Result",
                onBack: { dismiss() },
                trailingButton: AnyView(saveButton)
            )
            .padding(.top, 8)

            Spacer()

            // Photo with compare + edit icon
            ZStack(alignment: .bottomTrailing) {
                Image(uiImage: isHoldingCompare ? originalImage : editedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous))
                    .animation(.easeInOut(duration: 0.15), value: isHoldingCompare)

                // Edit again button (if available)
                if canEditMore {
                    HStack {
                        Spacer()
                        Button { navigateToEdit = true } label: {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.black.opacity(0.62)))
                                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(ArtimindDS.Spacing.sm)
                }
            }
            .padding(.horizontal, 16)
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

            Spacer()

            // Action buttons
            actionButtons
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToEdit) {
            TextEditPhotoView(
                image: editedImage,
                originalImage: originalImage,
                editCount: editCount,
                maxEdits: maxEdits
            )
        }
        .navigationDestination(isPresented: $navigateToStartOver) {
            TextEditPhotoView(
                image: originalImage,
                originalImage: originalImage,
                editCount: 0,
                maxEdits: maxEdits
            )
        }
        .overlay(alignment: .top) {
            if showSavedToast {
                savedToast
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 70)
            }
        }
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button { savePhoto() } label: {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Action buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                resultButton(title: "Share")
                resultButton(title: "Create Video")
            }

            if !canEditMore {
                Button { navigateToStartOver = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Start over")
                            .font(AppFont.dmSans(.bold, size: 15))
                    }
                    .foregroundStyle(ArtimindDS.ColorToken.yellow)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                            .fill(ArtimindDS.ColorToken.yellowDark)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, ArtimindDS.Size.sidePadding)
        .padding(.bottom, 36)
    }

    private func resultButton(title: String) -> some View {
        Button {} label: {
            Text(title)
                .font(AppFont.dmSans(.bold, size: 15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
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

    // MARK: - Save

    private func savePhoto() {
        withAnimation(.spring(response: 0.4)) {
            showSavedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showSavedToast = false }
        }
    }

    // MARK: - Toast

    private var savedToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColor.success)
            Text("Saved to Memory Space")
                .font(AppFont.dmSans(.medium, size: 14))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule(style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        TextEditResultView(
            originalImage: UIImage(named: "hero-memory")!,
            editedImage: UIImage(named: "hero-memory")!,
            editCount: 1,
            maxEdits: 3
        )
    }
    .preferredColorScheme(.dark)
}
