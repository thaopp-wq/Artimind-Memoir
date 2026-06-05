import SwiftUI

struct PhotoRestoreProcessingView: View {
    let image: UIImage
    var isColorize: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToResult = false
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            // Full screen user photo — desaturated + darkened
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .saturation(0)
                .brightness(-0.2)
                .ignoresSafeArea()

            // Dark overlay
            Color.black.opacity(0.4).ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                // Nav bar
                NavBarView(title: isColorize ? "Colorizing photo" : "Recovering photo", onBack: { dismiss() })
                    .padding(.top, 8)

                Spacer()

                // Center: spinner + text
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.3)
                        .tint(.white)
                        .padding(.bottom, 4)

                    Text(isColorize ? "Colorizing your photo..." : "Recovering your photo...")
                        .font(AppFont.cormorant(.bold, size: 28))
                        .foregroundStyle(.white)

                    Text("This may take a few seconds")
                        .font(AppFont.dmSans(.regular, size: 14))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .opacity(textOpacity)

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                textOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                navigateToResult = true
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            PhotoRestoreResultView(
                originalImage: image,
                restoredImage: applyFakeRestore(to: image)
            )
        }
    }

    private func applyFakeRestore(to input: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: input) else { return input }
        let context = CIContext()
        var output = ciImage

        if let sharpen = CIFilter(name: "CISharpenLuminance") {
            sharpen.setValue(output, forKey: kCIInputImageKey)
            sharpen.setValue(0.8, forKey: kCIInputSharpnessKey)
            if let result = sharpen.outputImage { output = result }
        }
        if let vibrance = CIFilter(name: "CIVibrance") {
            vibrance.setValue(output, forKey: kCIInputImageKey)
            vibrance.setValue(0.6, forKey: "inputAmount")
            if let result = vibrance.outputImage { output = result }
        }
        if let contrast = CIFilter(name: "CIColorControls") {
            contrast.setValue(output, forKey: kCIInputImageKey)
            contrast.setValue(1.08, forKey: kCIInputContrastKey)
            contrast.setValue(0.02, forKey: kCIInputBrightnessKey)
            if let result = contrast.outputImage { output = result }
        }

        guard let cgImage = context.createCGImage(output, from: ciImage.extent) else { return input }
        return UIImage(cgImage: cgImage, scale: input.scale, orientation: input.imageOrientation)
    }
}

#Preview {
    NavigationStack {
        PhotoRestoreProcessingView(image: UIImage(named: "hero-memory")!)
    }
    .preferredColorScheme(.dark)
}
