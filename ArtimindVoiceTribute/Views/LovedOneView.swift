import SwiftUI

struct LovedOneView: View {
    @Binding var selectedTab: Int
    @State private var selectedSegment = 0
    @State private var navigateToAddPhotos = false

    let segments = ["All", "Parents", "Siblings", "Grandparents", "Friends"]

    let albums: [(title: String, duration: String, count: Int, buttonLabel: String, gradientColors: [Color])] = [
        (
            title: "Dad's garden adventures",
            duration: "00:50",
            count: 6,
            buttonLabel: "Get Video",
            gradientColors: [Color(hex: "#2D2B1B"), Color(hex: "#1E1B10"), Color(hex: "#141419")]
        ),
        (
            title: "Mom's birthday memories",
            duration: "01:15",
            count: 8,
            buttonLabel: "Get Album",
            gradientColors: [Color(hex: "#2D1B2D"), Color(hex: "#1E101E"), Color(hex: "#141419")]
        ),
        (
            title: "Grandpa's stories",
            duration: "01:00",
            count: 10,
            buttonLabel: "Get Video",
            gradientColors: [Color(hex: "#1B2D2D"), Color(hex: "#101E1E"), Color(hex: "#141419")]
        ),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
                NavBarView(
                    title: "Loved Ones",
                    onBack: { selectedTab = 0 },
                    trailingButton: AnyView(
                        Button {
                            navigateToAddPhotos = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Add")
                                    .font(AppFont.dmSans(.semibold, size: 13))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppColor.brandMain)
                            .clipShape(Capsule())
                        }
                    )
                )
                .padding(.top, 8)

                // Segmented control
                segmentedControl
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                // Album list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(0..<albums.count, id: \.self) { i in
                            AlbumCardView(
                                title: albums[i].title,
                                duration: albums[i].duration,
                                count: albums[i].count,
                                showButton: true,
                                buttonLabel: albums[i].buttonLabel,
                                gradientColors: albums[i].gradientColors
                            )
                        }

                        // Bottom spacing
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
            }

        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToAddPhotos) {
            AddPhotosView(selectedTab: $selectedTab)
        }
    }

    // MARK: - Segmented Control
    private var segmentedControl: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<segments.count, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedSegment = i
                        }
                    } label: {
                        Text(segments[i])
                            .font(AppFont.dmSans(i == selectedSegment ? .semibold : .regular, size: 14))
                            .foregroundColor(i == selectedSegment ? .black : AppColor.labelSecondary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                Group {
                                    if i == selectedSegment {
                                        Color.white
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        i == selectedSegment
                                            ? Color.clear
                                            : Color.white.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }
}

#Preview {
    NavigationStack {
        LovedOneView(selectedTab: .constant(2))
    }
}
