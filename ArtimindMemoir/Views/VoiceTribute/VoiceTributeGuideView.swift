import SwiftUI

struct VoiceTributeGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var session = VoiceTributeSession.shared
    @State private var navigateToPhoto = false

    var preselectedImageName: String?

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Voice Tribute", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    heroSection
                    categorySection
                    useCasesSection
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }

            ctaButton
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            session.reset()
            if let name = preselectedImageName, let img = UIImage(named: name) {
                session.photo = img
            }
        }
        .navigationDestination(isPresented: $navigateToPhoto) {
            if preselectedImageName != nil {
                // Skip photo step, go to audio
                VoiceTributeAudioView()
            } else {
                VoiceTributePhotoView()
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 14) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(ArtimindDS.ColorToken.yellow)
                .padding(.top, 8)

            Text("AI Voice Tribute")
                .font(AppFont.cormorant(.bold, size: 28))
                .foregroundStyle(.white)

            Text("Bring a photo to life with voice. Upload a portrait, add a voice clip and script \u{2014} AI creates a video of them speaking.")
                .font(AppFont.dmSans(.regular, size: 14))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    // MARK: - Category picker

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What\u{2019}s this tribute for?")
                .font(AppFont.dmSans(.semibold, size: 16))
                .foregroundStyle(.white)

            let columns = [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
            ]

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(TributeCategory.allCases) { cat in
                    Button { session.category = cat } label: {
                        VStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 20))
                            Text(cat.rawValue)
                                .font(AppFont.dmSans(.medium, size: 12))
                                .lineLimit(1)
                        }
                        .foregroundStyle(session.category == cat ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous)
                                .fill(session.category == cat
                                      ? ArtimindDS.ColorToken.yellow
                                      : ArtimindDS.ColorToken.panel)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous)
                                .stroke(session.category == cat
                                        ? Color.clear
                                        : ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Use cases

    private var useCasesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What you can create")
                .font(AppFont.dmSans(.semibold, size: 16))
                .foregroundStyle(.white)

            useCaseRow(icon: "candle.fill", text: "A message from a loved one who\u{2019}s passed away")
            useCaseRow(icon: "gift.fill", text: "A birthday greeting in their own voice")
            useCaseRow(icon: "heart.fill", text: "Wedding speech from someone who can\u{2019}t attend")
            useCaseRow(icon: "clock.fill", text: "Preserve a family elder\u{2019}s voice for the future")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    private func useCaseRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(ArtimindDS.ColorToken.yellow)
                .frame(width: 22)
            Text(text)
                .font(AppFont.dmSans(.regular, size: 13))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
        }
    }

    // MARK: - CTA

    private var ctaButton: some View {
        Button { navigateToPhoto = true } label: {
            Text("Get Started")
                .font(AppFont.dmSans(.bold, size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Capsule().fill(AppColor.brandMain))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, ArtimindDS.Size.sidePadding)
        .padding(.bottom, 36)
    }
}

#Preview {
    NavigationStack {
        VoiceTributeGuideView()
    }
    .preferredColorScheme(.dark)
}
