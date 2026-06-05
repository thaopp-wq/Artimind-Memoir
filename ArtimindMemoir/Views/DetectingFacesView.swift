import SwiftUI

import Photos

struct DetectingFacesView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    let selectedAssets: [PHAsset]

    @State private var navigateToGenerating = false
    @State private var navigateToFailed = false
    @State private var navigateToPaywall = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            Color.black.ignoresSafeArea().opacity(0.55)

            // Spinner — sits at the exact center of the screen.
            spinner
                .frame(width: 32, height: 32)

            // Caption — laid out below the spinner without constraining its width.
            VStack(spacing: 6) {
                Text("Detecting your loved one's face")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                Text("This may take a few seconds")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 0.92, green: 0.92, blue: 0.96).opacity(0.6))
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .offset(y: 70)

            VStack {
                HStack {
                    GlassBackButton(action: { dismiss() })
                    Spacer()
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, 8)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $navigateToGenerating) {
            GeneratingView(selectedTab: $selectedTab)
        }
        .navigationDestination(isPresented: $navigateToFailed) {
            DetectionFailedView(selectedTab: $selectedTab)
        }
        .navigationDestination(isPresented: $navigateToPaywall) {
            PaywallView(
                selectedTab: $selectedTab,
                onContinue: {
                    navigateToPaywall = false
                    navigateToGenerating = true
                },
                onClose: {
                    NotificationCenter.default.post(name: .popGenerationFlow, object: nil)
                }
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if detectFaces(in: selectedAssets) {
                    if GenerationManager.shared.isPro {
                        navigateToGenerating = true
                    } else {
                        navigateToPaywall = true
                    }
                } else {
                    GenerationManager.shared.ineligibleAssetIDs =
                        Set(selectedAssets.map(\.localIdentifier))
                    navigateToFailed = true
                }
            }
        }
    }

    private func detectFaces(in assets: [PHAsset]) -> Bool {
        // QA mode: every input is treated as a fail so the failure screen is
        // always reachable. Flip back to real detection when re-enabling the
        // happy path. (Existing one-shot `forceDetectionFailure` flag is kept
        // for parity with the AddPhotosView long-press flow.)
        if GenerationManager.shared.forceDetectionFailure {
            GenerationManager.shared.forceDetectionFailure = false
        }
        _ = assets
        return false
    }

    /// TimelineView-driven rotation — guarantees a perfectly smooth continuous
    /// spin (no stutter on the SwiftUI `repeatForever` loop boundary).
    private var spinner: some View {
        TimelineView(.animation) { context in
            let seconds = context.date.timeIntervalSinceReferenceDate
            let angle = seconds.truncatingRemainder(dividingBy: 1.0) * 360

            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.225), lineWidth: 2.6)
                )
                .rotationEffect(.degrees(angle))
        }
    }
}

#Preview {
    NavigationStack {
        DetectingFacesView(selectedTab: .constant(0), selectedAssets: [])
    }
    .preferredColorScheme(.dark)
}
