import SwiftUI

struct FloatingTabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, label: String)] = [
        ("house.fill", "HOME"),
        ("film.fill", "MOMENTS"),
        ("heart.fill", "LOVED ONE"),
        ("photo.fill", "RESTORE"),
    ]

    var body: some View {
        HStack(spacing: 12) {
            // Main tab pills container
            HStack(spacing: 2) {
                ForEach(0..<tabs.count, id: \.self) { i in
                    TabItemView(
                        icon: tabs[i].icon,
                        label: tabs[i].label,
                        isSelected: selectedTab == i
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = i
                        }
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .background(Color.black.opacity(0.6))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
            )

            // Profile/search button
            Button {} label: {
                Image(systemName: "person.fill")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(AppColor.tabInactive)
                    .frame(width: 52, height: 52)
            }
            .background(.ultraThinMaterial)
            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
}

struct TabItemView: View {
    let icon: String
    let label: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(isSelected ? AppColor.tabActive : AppColor.tabInactive)

            Text(label)
                .font(AppFont.dmSans(.regular, size: 9))
                .foregroundColor(isSelected ? AppColor.tabActive : AppColor.tabInactive)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: 64, height: 50)
        .background(
            Group {
                if isSelected {
                    Capsule()
                        .fill(AppColor.tabActive.opacity(0.15))
                } else {
                    Color.clear
                }
            }
        )
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        VStack {
            Spacer()
            FloatingTabBar(selectedTab: .constant(0))
        }
    }
}
