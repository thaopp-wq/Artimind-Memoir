import SwiftUI
import UIKit

struct GeneratingView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int

    @ObservedObject private var generator = GenerationManager.shared
    @State private var navigateToResult = false

    private var progress: CGFloat { generator.progress }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    GlassBackButton(action: handleBack)
                    Spacer()
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, 8)
                .frame(height: 54)

                Spacer(minLength: 36)

                generationPreview
                    .padding(.horizontal, 30)

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Int(progress * 100))%")
                        .font(AppFont.cormorant(.bold, size: 36))
                        .foregroundColor(.white)
                        .monospacedDigit()

                    Text("Just a sec... the magic is happening ✨")
                        .font(AppFont.dmSans(.semibold, size: 15))
                        .foregroundColor(.white)

                    progressBar
                        .padding(.top, 28)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 38)
                .padding(.top, 54)

                Spacer(minLength: 128)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView()
        }
        .onAppear {
            generator.isGeneratingScreenVisible = true
            if !generator.isGenerating && !generator.hasPendingResult {
                generator.start()
            }
        }
        .onDisappear {
            generator.isGeneratingScreenVisible = false
        }
        .onChange(of: generator.hasPendingResult) { _, ready in
            if ready { navigateToResult = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            LiveActivityController.shared.update(progress: Double(generator.progress))
        }
    }

    private func handleBack() {
        // Keep generating in the background — DO NOT cancel the manager.
        selectedTab = 1
        NotificationCenter.default.post(name: .popGenerationFlow, object: nil)
    }

    private var generationPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#EEC3AC"), Color(hex: "#A3B266"), Color(hex: "#100F0D")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 0) {
                portraitGradient(
                    colors: [Color(hex: "#D9A088"), Color(hex: "#8F715F"), Color(hex: "#18110F")]
                )
                .blur(radius: 2.8)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.white.opacity(0.82))
                        .frame(width: 2)
                        .offset(x: 158)
                }

                portraitGradient(
                    colors: [Color(hex: "#C8D778"), Color(hex: "#917760"), Color(hex: "#15110E")]
                )
                .blur(radius: 3.8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            sparkles
                .offset(x: 0, y: -18)
        }
        .frame(height: 424)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func portraitGradient(colors: [Color]) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)

            Circle()
                .fill(Color.black.opacity(0.22))
                .frame(width: 92, height: 92)
                .offset(y: -188)

            Ellipse()
                .fill(Color.black.opacity(0.20))
                .frame(width: 150, height: 210)
                .offset(y: 78)
        }
        .frame(maxWidth: .infinity)
    }

    private var sparkles: some View {
        ZStack {
            ForEach(Array(sparkleItems.enumerated()), id: \.offset) { _, item in
                Text(item.text)
                    .font(.system(size: item.size, weight: .medium))
                    .foregroundColor(.white.opacity(item.opacity))
                    .offset(x: item.x, y: item.y)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sparkleItems: [(text: String, size: CGFloat, opacity: Double, x: CGFloat, y: CGFloat)] {
        [
            ("✦", 10, 0.9, -24, -144),
            ("✦", 18, 0.9, -16, -118),
            ("✧", 11, 0.75, 12, -114),
            ("✦", 12, 0.8, 24, -84),
            ("✦", 16, 0.88, 34, -54),
            ("✧", 10, 0.72, -3, -35),
            ("✦", 15, 0.86, 42, -12),
            ("✧", 11, 0.76, 12, 36),
            ("✦", 16, 0.85, 30, 86)
        ]
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.88))
                    .frame(height: 12)

                Capsule()
                    .fill(Color(hex: "#C90F1C"))
                    .frame(width: proxy.size.width * progress, height: 12)
                    .animation(.easeInOut(duration: 0.25), value: progress)
            }
        }
        .frame(height: 12)
    }

}

#Preview {
    NavigationStack {
        GeneratingView(selectedTab: .constant(1))
    }
    .preferredColorScheme(.dark)
}
