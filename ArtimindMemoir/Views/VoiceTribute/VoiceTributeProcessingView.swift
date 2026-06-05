import SwiftUI

private struct ProcessingStep: Identifiable {
    let id = UUID()
    let text: String
    var status: StepStatus = .pending

    enum StepStatus {
        case pending, inProgress, completed
    }
}

struct VoiceTributeProcessingView: View {
    @ObservedObject private var session = VoiceTributeSession.shared
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToResult = false
    @State private var haloRotation: Double = 0
    @State private var steps: [ProcessingStep] = [
        .init(text: "Remembering their face"),
        .init(text: "Listening to their voice..."),
        .init(text: "Bringing their words to life"),
        .init(text: "They\u{2019}re almost here"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            NavBarView(title: "Bringing Them Back", onBack: { dismiss() })
                .padding(.top, 8)

            Spacer()

            // Avatar with halo ring
            ZStack {
                // Track ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 3)
                    .frame(width: 220, height: 220)

                // Animated arc
                Circle()
                    .trim(from: 0, to: 0.28)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(haloRotation))

                // Photo
                if let photo = session.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 190, height: 190)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(ArtimindDS.ColorToken.panel)
                        .frame(width: 190, height: 190)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                        )
                }
            }

            Spacer().frame(height: 32)

            // Title
            Text("We\u{2019}re bringing them\nback to you")
                .font(AppFont.cormorant(.bold, size: 28))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 24)

            // Steps list
            VStack(alignment: .leading, spacing: 10) {
                ForEach(steps) { step in
                    HStack(spacing: 8) {
                        Text(step.text)
                            .font(AppFont.dmSans(.regular, size: 14))
                            .foregroundStyle(stepColor(step.status))

                        if step.status == .completed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(ArtimindDS.ColorToken.sage)
                        } else if step.status == .inProgress {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: step.status == .pending ? .center : .center)
                }
            }

            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startAnimation()
            startSteps()
        }
        .navigationDestination(isPresented: $navigateToResult) {
            VoiceTributeResultView()
        }
    }

    private func stepColor(_ status: ProcessingStep.StepStatus) -> Color {
        switch status {
        case .completed: return ArtimindDS.ColorToken.textSecondary
        case .inProgress: return .white
        case .pending: return ArtimindDS.ColorToken.textTertiary
        }
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
            haloRotation = 360
        }
    }

    private func startSteps() {
        let delays: [Double] = [0.0, 1.2, 2.5, 3.8]

        for (i, delay) in delays.enumerated() {
            // Start step
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if i > 0 { steps[i - 1].status = .completed }
                    steps[i].status = .inProgress
                }
            }
        }

        // Complete last step + navigate
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                steps[3].status = .completed
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            navigateToResult = true
        }
    }
}

#Preview {
    NavigationStack {
        VoiceTributeProcessingView()
    }
    .preferredColorScheme(.dark)
}
