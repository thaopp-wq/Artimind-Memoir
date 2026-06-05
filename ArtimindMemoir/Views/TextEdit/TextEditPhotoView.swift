import SwiftUI

struct TextEditPhotoView: View {
    let image: UIImage
    var originalImage: UIImage? = nil
    var editCount: Int = 0
    var maxEdits: Int = 3

    @Environment(\.dismiss) private var dismiss
    @State private var promptText = ""
    @State private var isProcessing = false
    @State private var editedImage: UIImage?
    @State private var navigateToResult = false
    @State private var showInputBar = true
    @FocusState private var isFocused: Bool

    private var rootImage: UIImage { originalImage ?? image }
    private var hasText: Bool { !promptText.trimmingCharacters(in: .whitespaces).isEmpty }

    private let suggestions = [
        "Remove background",
        "Enhance colors",
        "Fix lighting",
    ]

    var body: some View {
        ZStack {
            // Full-screen photo
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Processing overlay
            if isProcessing {
                Color.black.opacity(0.5).ignoresSafeArea()
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.4)
                        .tint(ArtimindDS.ColorToken.yellow)
                    Text("Editing...")
                        .font(AppFont.dmSans(.medium, size: 15))
                        .foregroundStyle(.white)
                }
            }

            // UI overlays
            VStack(spacing: 0) {
                // Top bar
                // Solid dark control (§6.6)
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
                .padding(.top, ArtimindDS.Spacing.xs)

                Spacer()

                // Bottom input area
                if !isProcessing {
                    inputArea
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = false
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let edited = editedImage {
                TextEditResultView(
                    originalImage: rootImage,
                    editedImage: edited,
                    editCount: editCount + 1,
                    maxEdits: maxEdits
                )
            }
        }
    }

    // MARK: - Input Area

    private var inputArea: some View {
        VStack(spacing: 8) {
            // Suggestion chips — always visible
            if !isProcessing {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button { promptText = suggestion } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12))
                                        .foregroundStyle(ArtimindDS.ColorToken.yellow)
                                    Text(suggestion)
                                        .font(AppFont.dmSans(.semibold, size: 14))
                                        .foregroundStyle(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule().fill(Color.white.opacity(0.12))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            // Text field row
            HStack(spacing: 8) {
                TextField("Describe what to change...", text: $promptText)
                    .font(AppFont.dmSans(.regular, size: 15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .focused($isFocused)

                Button { sendPrompt() } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(hasText ? .black : .white.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle().fill(hasText ? ArtimindDS.ColorToken.yellow : Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!hasText || isProcessing)
                .padding(.trailing, 6)
            }
            .background(
                Capsule().fill(Color.white.opacity(0.08))
            )
            .overlay(
                Capsule().stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "#F59E0B"),
                            Color(hex: "#EF4444"),
                            Color(hex: "#A855F7"),
                            Color(hex: "#3B82F6"),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
            )
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 28)
    }

    // MARK: - Send prompt

    private func sendPrompt() {
        let prompt = promptText.trimmingCharacters(in: .whitespaces)
        guard !prompt.isEmpty else { return }

        isFocused = false
        isProcessing = true
        promptText = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            editedImage = applyFakeEdit(to: image)
            isProcessing = false
            navigateToResult = true
        }
    }

    // MARK: - Fake edit

    private func applyFakeEdit(to input: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: input) else { return input }
        let context = CIContext()
        var output = ciImage

        if let filter = CIFilter(name: "CIColorControls") {
            filter.setValue(output, forKey: kCIInputImageKey)
            filter.setValue(CGFloat.random(in: 1.02...1.15), forKey: kCIInputContrastKey)
            filter.setValue(CGFloat.random(in: 0.95...1.1), forKey: kCIInputSaturationKey)
            filter.setValue(CGFloat.random(in: -0.02...0.03), forKey: kCIInputBrightnessKey)
            if let result = filter.outputImage { output = result }
        }

        guard let cgImage = context.createCGImage(output, from: ciImage.extent) else { return input }
        return UIImage(cgImage: cgImage, scale: input.scale, orientation: input.imageOrientation)
    }
}

#Preview {
    NavigationStack {
        TextEditPhotoView(image: UIImage(named: "hero-memory")!)
    }
    .preferredColorScheme(.dark)
}
