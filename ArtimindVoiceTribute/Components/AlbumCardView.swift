import SwiftUI

struct AlbumCardView: View {
    let title: String
    let duration: String
    let count: Int
    var showButton: Bool = true
    var buttonLabel: String = "Get Album"
    var gradientColors: [Color] = [
        Color(hex: "#3A2A2A"),
        Color(hex: "#2C2020"),
        Color(hex: "#1C1C1E")
    ]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image placeholder
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Subtle texture overlay
            Rectangle()
                .fill(Color.white.opacity(0.03))

            // Bottom gradient overlay
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
            }

            // Bottom content
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 13) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.7))
                            Text(duration)
                                .font(AppFont.dmSans(.regular, size: 11))
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.7))
                            Text("\(count)")
                                .font(AppFont.dmSans(.regular, size: 11))
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                    }
                    Text(title)
                        .font(AppFont.dmSans(.semibold, size: 15))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }

                Spacer()

                if showButton {
                    Text(buttonLabel)
                        .font(AppFont.dmSans(.semibold, size: 15))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
            .padding(15)
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius))
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        VStack(spacing: 12) {
            AlbumCardView(
                title: "Teaching baseball",
                duration: "00:45",
                count: 5,
                showButton: true,
                buttonLabel: "Get Album"
            )
            AlbumCardView(
                title: "Summer Vacation 2024",
                duration: "01:20",
                count: 8,
                showButton: true,
                buttonLabel: "Get Video",
                gradientColors: [Color(hex: "#1A2A3A"), Color(hex: "#1C2535"), Color(hex: "#1C1C1E")]
            )
            AlbumCardView(
                title: "Family Reunion",
                duration: "00:30",
                count: 3,
                showButton: false
            )
        }
        .padding(.horizontal, 16)
    }
}
