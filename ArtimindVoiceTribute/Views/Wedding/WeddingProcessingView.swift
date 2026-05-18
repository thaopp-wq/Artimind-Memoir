import SwiftUI

struct WeddingProcessingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = WeddingTributeManager.shared
    @State private var navigateToOutput = false
    @State private var showErrorModal = false
    @State private var pulseScale: CGFloat = 1.0

    private var template: WeddingTemplate? { manager.selectedTemplate }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: "Bringing Them Back", onBack: { dismiss() })
                    .padding(.top, 8)

                Spacer(minLength: 40)

                // Avatar circle with circular progress ring
                avatarPreview
                    .padding(.bottom, 28)

                // Hero text
                Text("We're bringing them\nback to you")
                    .font(AppFont.cormorant(.bold, size: 28))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 24)

                // Steps
                stepsView

                Spacer()
            }

            if showErrorModal {
                errorModalOverlay
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $navigateToOutput) {
            WeddingOutputPreviewView()
        }
        .onAppear {
            if !manager.isProcessing && !manager.processingComplete {
                manager.startProcessing()
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.06
            }
        }
        .onChange(of: manager.processingComplete) { _, complete in
            if complete { navigateToOutput = true }
        }
        .onChange(of: manager.processingFailed) { _, failed in
            if failed { showErrorModal = true }
        }
    }

    // MARK: - Avatar Preview

    private var avatarPreview: some View {
        ZStack {
            // Track ring (background)
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 3)
                .frame(width: 200, height: 200)

            // Progress ring
            Circle()
                .trim(from: 0, to: manager.overallProgress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: manager.overallProgress)

            // Outer pulse ring
            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                .frame(width: 220, height: 220)
                .scaleEffect(pulseScale)

            // Thumbnail image
            if let imageName = template?.thumbnail, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 170)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(hex: "#2A2A2C"))
                    .frame(width: 170, height: 170)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.3))
                    )
            }
        }
    }

    // MARK: - Steps

    private var stepsView: some View {
        VStack(spacing: 6) {
            ForEach(WeddingProcessingStep.allCases, id: \.rawValue) { step in
                stepRow(step)
            }
        }
    }

    private func stepRow(_ step: WeddingProcessingStep) -> some View {
        let status = manager.stepStatuses[step] ?? .pending

        return HStack(spacing: 8) {
            Text(stepLabel(step, status: status))
                .font(AppFont.dmSans(.regular, size: 14))
                .foregroundColor(stepColor(status))

            stepIcon(status)
        }
        .animation(.easeInOut(duration: 0.4), value: status)
    }

    private func stepLabel(_ step: WeddingProcessingStep, status: WeddingStepStatus) -> String {
        let text: String
        switch step {
        case .analyzePhotos: text = "Remembering their face"
        case .analyzeAudio: text = "Listening to their voice"
        case .generateVoice: text = "Bringing their words to life"
        case .generateVideo: text = "They're almost here"
        }
        return status == .inProgress ? text + "..." : text
    }

    private func stepColor(_ status: WeddingStepStatus) -> Color {
        switch status {
        case .completed: return Color.white.opacity(0.5)
        case .inProgress: return .white
        case .failed: return Color(hex: "#F26B8C")
        case .pending: return Color.white.opacity(0.25)
        }
    }

    @ViewBuilder
    private func stepIcon(_ status: WeddingStepStatus) -> some View {
        switch status {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.5))
        case .inProgress:
            ProgressView()
                .scaleEffect(0.6)
                .tint(.white)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#F26B8C"))
        case .pending:
            EmptyView()
        }
    }

    // MARK: - Error Modal

    private var errorModalOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(Color(hex: "#F2333F"))

                Text("Generation Failed")
                    .font(AppFont.dmSans(.semibold, size: 22))
                    .foregroundColor(.white)

                Text("Something went wrong while generating your video. Please try again.")
                    .font(AppFont.dmSans(.regular, size: 14))
                    .foregroundColor(AppColor.labelSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Button {
                    showErrorModal = false
                    manager.cancelProcessing()
                    NotificationCenter.default.post(name: .popWeddingFlow, object: nil)
                } label: {
                    Text("Back to Home")
                        .font(AppFont.dmSans(.bold, size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(Capsule().fill(Color(hex: "#8E0612")))
                }
                .buttonStyle(.plain)
            }
            .padding(28).frame(maxWidth: 320)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color(hex: "#1C1C1E")))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }
}

#Preview {
    NavigationStack {
        WeddingProcessingView()
            .onAppear { WeddingTributeManager.shared.selectTemplate(WeddingTemplate.samples[0]) }
    }
    .preferredColorScheme(.dark)
}
