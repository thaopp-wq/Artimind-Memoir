import SwiftUI

struct MemorySpaceView: View {
    @Binding var selectedTab: Int
    @State private var selectedSegment = 2  // "Living Album" selected by default

    let segments = ["Life Moments", "Restoration", "Living Album"]

    let lifeAlbums: [(title: String, duration: String, count: Int, gradientColors: [Color])] = [
        (
            title: "Teaching baseball",
            duration: "00:45",
            count: 5,
            gradientColors: [Color(hex: "#2D1B1B"), Color(hex: "#1E1010"), Color(hex: "#141419")]
        ),
        (
            title: "Morning garden walks",
            duration: "01:10",
            count: 7,
            gradientColors: [Color(hex: "#1A2D1A"), Color(hex: "#102010"), Color(hex: "#141419")]
        ),
        (
            title: "Birthday surprise 2023",
            duration: "00:55",
            count: 9,
            gradientColors: [Color(hex: "#1A1A2D"), Color(hex: "#101030"), Color(hex: "#141419")]
        ),
    ]

    let restorationAlbums: [(title: String, duration: String, count: Int, gradientColors: [Color])] = [
        (
            title: "Grandpa's 1960s photos",
            duration: "00:30",
            count: 4,
            gradientColors: [Color(hex: "#2D2B1B"), Color(hex: "#1E1B10"), Color(hex: "#141419")]
        ),
        (
            title: "Family archive 1985",
            duration: "00:40",
            count: 6,
            gradientColors: [Color(hex: "#2D1B2D"), Color(hex: "#1E101E"), Color(hex: "#141419")]
        ),
    ]

    let livingAlbums: [(title: String, duration: String, count: Int, gradientColors: [Color])] = [
        (
            title: "Summer 2024 highlights",
            duration: "01:20",
            count: 12,
            gradientColors: [Color(hex: "#1B2D2D"), Color(hex: "#101E1E"), Color(hex: "#141419")]
        ),
        (
            title: "Weekend at the cabin",
            duration: "00:50",
            count: 8,
            gradientColors: [Color(hex: "#2D1B1B"), Color(hex: "#1E1010"), Color(hex: "#141419")]
        ),
        (
            title: "City adventures",
            duration: "01:05",
            count: 10,
            gradientColors: [Color(hex: "#1A1A2D"), Color(hex: "#101030"), Color(hex: "#141419")]
        ),
    ]

    private var currentAlbums: [(title: String, duration: String, count: Int, gradientColors: [Color])] {
        switch selectedSegment {
        case 0: return lifeAlbums
        case 1: return restorationAlbums
        default: return livingAlbums
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                NavBarView(
                    title: "Memory Space",
                    onBack: { selectedTab = 0 }
                )
                .padding(.top, 8)

                // Segmented glass pill control
                segmentedGlassControl
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                // Album list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if currentAlbums.isEmpty {
                            emptyState
                        } else {
                            ForEach(0..<currentAlbums.count, id: \.self) { i in
                                AlbumCardView(
                                    title: currentAlbums[i].title,
                                    duration: currentAlbums[i].duration,
                                    count: currentAlbums[i].count,
                                    showButton: false,
                                    gradientColors: currentAlbums[i].gradientColors
                                )
                            }
                        }

                        // Bottom spacing for floating tab bar
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
            }

        }
        .navigationBarHidden(true)
    }

    // MARK: - Segmented Glass Control
    private var segmentedGlassControl: some View {
        HStack(spacing: 0) {
            ForEach(0..<segments.count, id: \.self) { i in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedSegment = i
                    }
                } label: {
                    Text(segments[i])
                        .font(AppFont.dmSans(i == selectedSegment ? .semibold : .regular, size: 13))
                        .foregroundColor(i == selectedSegment ? .black : AppColor.labelSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(
                            Group {
                                if i == selectedSegment {
                                    Capsule().fill(Color.white)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.4))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColor.backgroundSecondary)
                    .frame(width: 80, height: 80)
                Image(systemName: "photo.stack")
                    .font(.system(size: 32))
                    .foregroundColor(Color.white.opacity(0.2))
            }
            .padding(.top, 60)

            Text("No albums yet")
                .font(AppFont.cormorant(.bold, size: 22))
                .foregroundColor(AppColor.labelPrimary)

            Text("Create your first AI album to see it here.")
                .font(AppFont.dmSans(.regular, size: 14))
                .foregroundColor(AppColor.labelSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    NavigationStack {
        MemorySpaceView(selectedTab: .constant(3))
    }
}
