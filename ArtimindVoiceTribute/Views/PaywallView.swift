import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    /// Called when the user successfully unlocks Pro and should proceed to generation.
    var onContinue: () -> Void
    /// Called when the user dismisses without unlocking (back to theme list).
    var onClose: () -> Void = {}

    @State private var selectedPlan: Plan = .yearly
    @State private var navigateAfterUnlock = false

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, 8)

                Spacer(minLength: 12)

                heroBlock
                    .padding(.horizontal, 28)

                Spacer(minLength: 24)

                benefits
                    .padding(.horizontal, 24)

                Spacer(minLength: 24)

                planSelector
                    .padding(.horizontal, 20)

                continueButton
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                legalRow
                    .padding(.top, 12)
                    .padding(.bottom, 18)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: Background

    private var backgroundLayer: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(hex: "#1A1A1F"),
                    Color(hex: "#0B0B0E"),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color(hex: "#D6A55C").opacity(0.18), .clear],
                center: .top,
                startRadius: 6,
                endRadius: 320
            )
            .ignoresSafeArea()
        }
    }

    // MARK: Top Bar

    private var topBar: some View {
        HStack {
            Button {
                onClose()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.08)))
                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            Button {} label: {
                Text("Restore")
                    .font(AppFont.dmSans(.medium, size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Hero

    private var heroBlock: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                Text("PRO")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Capsule().fill(ArtimindDS.ColorToken.yellow))
            .padding(.bottom, 4)

            Text("Unlock the full memory")
                .font(AppFont.cormorant(.semibold, size: 30))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text("Bring loved ones to life in beautiful cinematic videos — only with Pro.")
                .font(AppFont.dmSans(.regular, size: 14))
                .foregroundColor(.white.opacity(0.68))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 4)
        }
    }

    // MARK: Benefits

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 14) {
            benefitRow(icon: "wand.and.stars", title: "Unlimited AI album generations")
            benefitRow(icon: "sparkles.tv", title: "HD video export with no watermark")
            benefitRow(icon: "person.crop.rectangle.stack", title: "Up to 13 photos per memory")
            benefitRow(icon: "bolt.fill", title: "Priority generation queue")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func benefitRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 30, height: 30)
                .background(Circle().fill(ArtimindDS.ColorToken.yellow))

            Text(title)
                .font(AppFont.dmSans(.medium, size: 15))
                .foregroundColor(.white)

            Spacer()
        }
    }

    // MARK: Plan Selector

    private var planSelector: some View {
        VStack(spacing: 10) {
            planRow(.yearly, headline: "Yearly", price: "$39.99 / year", caption: "Best value · 7-day free trial", badge: "SAVE 67%")
            planRow(.weekly, headline: "Weekly", price: "$4.99 / week", caption: "Cancel anytime", badge: nil)
        }
    }

    private func planRow(_ plan: Plan, headline: String, price: String, caption: String, badge: String?) -> some View {
        let selected = plan == selectedPlan

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { selectedPlan = plan }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(selected ? Color.white : Color.white.opacity(0.32), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle().fill(Color.white).frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(headline)
                            .font(AppFont.dmSans(.semibold, size: 15))
                            .foregroundColor(.white)
                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(ArtimindDS.ColorToken.yellow))
                        }
                    }
                    Text(caption)
                        .font(AppFont.dmSans(.regular, size: 12))
                        .foregroundColor(.white.opacity(0.55))
                }

                Spacer()

                Text(price)
                    .font(AppFont.dmSans(.semibold, size: 14))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(selected ? 0.10 : 0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? Color.white.opacity(0.55) : Color.white.opacity(0.10), lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Continue / CTA

    private var continueButton: some View {
        Button {
            GenerationManager.shared.isPro = true
            onContinue()
        } label: {
            HStack(spacing: 8) {
                Text("Continue")
                    .font(AppFont.dmSans(.bold, size: 16))
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .heavy))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Capsule().fill(Color.white))
            .shadow(color: Color.white.opacity(0.15), radius: 18, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var legalRow: some View {
        HStack(spacing: 18) {
            Text("Terms").legal()
            Circle().fill(Color.white.opacity(0.18)).frame(width: 3, height: 3)
            Text("Privacy").legal()
            Circle().fill(Color.white.opacity(0.18)).frame(width: 3, height: 3)
            Text("Restore").legal()
        }
    }

    enum Plan { case yearly, weekly }
}

private extension Text {
    func legal() -> some View {
        self
            .font(AppFont.dmSans(.regular, size: 11))
            .foregroundColor(.white.opacity(0.45))
    }
}

#Preview {
    NavigationStack {
        PaywallView(selectedTab: .constant(1), onContinue: {})
    }
    .preferredColorScheme(.dark)
}
