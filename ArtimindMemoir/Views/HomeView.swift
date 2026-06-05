import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var navigateToAddPhotos = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    topNavBar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    introSection
                        .padding(.horizontal, ArtimindDS.Size.sidePadding)
                        .padding(.top, 46)

                    HeroMemoryCard(onGetVideo: { navigateToAddPhotos = true })
                        .padding(.top, 28)

                    exploreSection
                        .padding(.horizontal, ArtimindDS.Size.sidePadding)
                        .padding(.top, 26)
                        .padding(.bottom, 120)
                }
                .frame(maxWidth: .infinity)
            }
            .background(ArtimindDS.ColorToken.appBackground)
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToAddPhotos) {
                AddPhotosView(selectedTab: $selectedTab)
            }
            .onReceive(NotificationCenter.default.publisher(for: .popGenerationFlow)) { _ in
                navigateToAddPhotos = false
            }
        }
    }

    // MARK: - Top Nav Bar

    private var topNavBar: some View {
        HStack {
            ArtLogo()
            Spacer()
            ArtBadge(title: "PRO", tone: .pro, icon: "sparkle")
        }
    }

    // MARK: - Intro Section

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("GOOD EVENING, NEW YORK")
                .font(ArtimindDS.Typography.eyebrow)
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .tracking(1.5)
                .padding(.bottom, 18)

            Text("What will you")
                .font(ArtimindDS.Typography.heroSerif)
                .foregroundStyle(.white)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("remember today")
                    .font(ArtimindDS.Typography.heroItalic)
                    .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                Text("?")
                    .font(ArtimindDS.Typography.heroItalic)
                    .foregroundStyle(.white.opacity(0.82))
            }
            .padding(.bottom, 12)

            Text("Every photo holds a story. Let us help you bring it back to life — in motion, in colour, and in memory.")
                .font(ArtimindDS.Typography.body)
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Explore Section

    private var exploreSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("More to explore")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .padding(.bottom, 2)

            ExploreCard(
                imageName: "explore-living-album",
                title: "Living Album",
                description: "Transform your memories into cinematic AI video albums.",
                badge: "New",
                badgeTone: .yellow,
                actionTitle: "Explore",
                onTap: { selectedTab = 1 }
            )

            ExploreCard(
                imageName: "explore-restore",
                title: "Restore & Colorize",
                description: "Heal faded, damaged, or black-and-white photos. Give them the care they deserve.",
                badge: "Free",
                badgeTone: .green,
                actionTitle: "Try It",
                onTap: { navigateToAddPhotos = true }
            )

            ExploreCard(
                imageName: "explore-loved-ones",
                title: "Loved Ones",
                description: "Bring a loved one back to life from a single photo. Watch them move, hear their voice.",
                badge: "New",
                badgeTone: .yellow,
                actionTitle: "Explore",
                onTap: { navigateToAddPhotos = true }
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .preferredColorScheme(.dark)
}
