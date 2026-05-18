import SwiftUI

struct AlbumThemeSpec: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let duration: String
    let photoCount: Int
    let buttonLabel: String
    let gradientColors: [Color]
    var imageName: String? = nil
    /// Width over height ratio of the generated video for this theme. Defaults to 9:16 (vertical).
    var aspectRatio: CGFloat = 9.0 / 16.0
}

struct ThemePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let theme: AlbumThemeSpec
    @Binding var selectedTab: Int
    @State private var navigateToAddPhotos = false

    var body: some View {
        VStack(spacing: 0) {
            navHeader
                .padding(.top, 8)

            heroCard
                .padding(.horizontal, 16)
                .padding(.top, 6)

            bottomInfo
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $navigateToAddPhotos) {
            AddPhotosView(selectedTab: $selectedTab)
        }
        .onReceive(NotificationCenter.default.publisher(for: .popGenerationFlow)) { _ in
            navigateToAddPhotos = false
        }
    }

    // MARK: Nav header — back button + centered title

    private var navHeader: some View {
        ZStack {
            Text(theme.title)
                .font(AppFont.cormorant(.semibold, size: 26))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 72)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                        .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 1))
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .frame(height: 54)
    }

    // MARK: Hero card — rounded photo with padding

    private var heroCard: some View {
        ZStack {
            Color.black
            cardBackground
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var cardBackground: some View {
        if let imageName = theme.imageName {
            GeometryReader { geo in
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
        } else {
            LinearGradient(
                colors: theme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: Bottom info — subtitle, pills, primary CTA

    private var bottomInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(theme.subtitle)
                .font(AppFont.cormorant(.regular, size: 20))
                .foregroundColor(Color.white.opacity(0.92))
                .lineSpacing(2)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                infoPill(icon: "photo.on.rectangle.angled", text: "\(theme.photoCount) photos")
                infoPill(icon: "clock", text: theme.duration)
                Spacer()
            }

            Button {
                GenerationManager.shared.selectedTheme = theme
                navigateToAddPhotos = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 15, weight: .semibold))
                    Text(theme.buttonLabel)
                        .font(AppFont.dmSans(.bold, size: 17))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#C90F1C"), Color(hex: "#8E0612")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }

    // MARK: Helpers

    private func infoPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text(text)
                .font(AppFont.dmSans(.medium, size: 12))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Capsule().fill(Color.white.opacity(0.08)))
        .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1))
    }

}

#Preview {
    NavigationStack {
        ThemePreviewView(
            theme: AlbumThemeSpec(
                title: "Teaching baseball",
                subtitle: "Imagine your parents' youth as a cinematic living album.",
                duration: "00:45",
                photoCount: 5,
                buttonLabel: "Get Album",
                gradientColors: [Color(hex: "#B9A27E"), Color(hex: "#4D463A"), Color.black],
                imageName: "hero-memory"
            ),
            selectedTab: .constant(1)
        )
    }
    .preferredColorScheme(.dark)
}
