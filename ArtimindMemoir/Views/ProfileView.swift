import SwiftUI

struct ProfileView: View {
    @Binding var selectedTab: Int

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: "Profile")
                    .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 16) {
                        avatarBlock
                        statsRow
                        menuList
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var avatarBlock: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 96, height: 96)
                Image(systemName: "person.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .glassBackground(shape: .circle)
            Text("Welcome back")
                .font(AppFont.dmSans(.semibold, size: 17))
                .foregroundStyle(.white)
            Text("Sign in to sync your Living Albums")
                .font(AppFont.dmSans(.regular, size: 13))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.top, 12)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "0", label: "Albums")
            statCard(value: "0", label: "Photos")
            statCard(value: "PRO", label: "Plan")
        }
        .padding(.top, 8)
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(AppFont.cormorant(.semibold, size: 22))
                .foregroundStyle(.white)
            Text(label)
                .font(AppFont.dmSans(.regular, size: 11))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .glassBackground(shape: .rounded(16))
    }

    private var menuList: some View {
        VStack(spacing: 8) {
            menuRow(icon: "sparkles", title: "Upgrade to PRO")
            menuRow(icon: "bell.fill", title: "Notifications")
            menuRow(icon: "questionmark.circle.fill", title: "Help & Support")
            menuRow(icon: "doc.text.fill", title: "Terms & Privacy")
        }
        .padding(.top, 4)
    }

    private func menuRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 32)
            Text(title)
                .font(AppFont.dmSans(.medium, size: 15))
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.35))
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .glassBackground(shape: .rounded(14))
    }
}

#Preview {
    NavigationStack {
        ProfileView(selectedTab: .constant(2))
    }
    .preferredColorScheme(.dark)
}
