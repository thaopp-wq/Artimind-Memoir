import SwiftUI

struct TextEditGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var navigateToEditor = false
    @State private var navigateToEditorPreselected = false

    var preselectedImageName: String?

    private let examplePrompts = [
        "Remove the person in the background",
        "Change the sky to sunset",
        "Add a smile to her face",
        "Remove scratches and stains",
        "Make the grass greener",
        "Replace background with a beach",
    ]

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Text Edit Guide", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // What you can do
                    examplesSection

                    // Tips
                    tipsSection
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
            if selectedImage != nil { navigateToEditor = true }
        }
        .navigationDestination(isPresented: $navigateToEditor) {
            if let img = selectedImage {
                TextEditPhotoView(image: img)
            }
        }
        .navigationDestination(isPresented: $navigateToEditorPreselected) {
            if let name = preselectedImageName, let img = UIImage(named: name) {
                TextEditPhotoView(image: img)
            }
        }
    }

    // MARK: - Examples

    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Describe any change")
                .font(AppFont.dmSans(.bold, size: 22))
                .foregroundStyle(.white)

            Text("Just type what you want \u{2014} AI will edit the photo for you.")
                .font(AppFont.dmSans(.regular, size: 13))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .lineSpacing(3)

            // Prompt chips
            FlowLayout(spacing: 8) {
                ForEach(examplePrompts, id: \.self) { prompt in
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundStyle(ArtimindDS.ColorToken.yellow)
                        Text(prompt)
                            .font(AppFont.dmSans(.regular, size: 12))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule(style: .continuous)
                            .fill(ArtimindDS.ColorToken.panelElevated)
                    )
                }
            }
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips")
                .font(AppFont.dmSans(.semibold, size: 16))
                .foregroundStyle(.white)

            tipRow(icon: "text.cursor", text: "Be specific \u{2014} \"remove red car on the left\" works better than \"clean up\"")
            tipRow(icon: "arrow.clockwise", text: "You can edit multiple times on the same photo")
            tipRow(icon: "globe", text: "Works in any language")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(ArtimindDS.ColorToken.yellow)
                .frame(width: 22)
            Text(text)
                .font(AppFont.dmSans(.regular, size: 13))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .lineSpacing(2)
        }
    }

    // MARK: - CTA

    private var ctaButtons: some View {
        VStack(spacing: 10) {
            if preselectedImageName != nil {
                Button { navigateToEditorPreselected = true } label: {
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

// MARK: - FlowLayout (wrapping horizontal layout)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}

#Preview {
    NavigationStack {
        TextEditGuideView()
    }
    .preferredColorScheme(.dark)
}
