import SwiftUI

struct DetectionFailedView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    GlassBackButton(action: { dismiss() })
                    Spacer()
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, 8)
                .frame(height: 54)

                Spacer()

                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 110, height: 110)
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(Color(hex: "#F26B8C"))
                    }
                    .glassBackground(shape: .circle)
                    .padding(.bottom, 8)

                    Text("No faces detected")
                        .font(AppFont.cormorant(.semibold, size: 28))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("We couldn't find a clear face in any of your photos. Try adding more photos or different ones with a visible face.")
                        .font(AppFont.dmSans(.regular, size: 14))
                        .foregroundStyle(.white.opacity(0.62))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 28)
                }

                Spacer()

                VStack(spacing: 10) {
                    Button {
                        // Collapse all screens above AddPhotosView so the user lands on the picker.
                        NotificationCenter.default.post(name: .returnToAddPhotos, object: nil)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Change Photos")
                                .font(AppFont.dmSans(.semibold, size: 16))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        // Collapse the whole generation flow back to the theme list.
                        NotificationCenter.default.post(name: .popGenerationFlow, object: nil)
                    } label: {
                        Text("Cancel")
                            .font(AppFont.dmSans(.semibold, size: 15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .glassBackground(shape: .capsule, interactive: true)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, 28)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        DetectionFailedView(selectedTab: .constant(0))
    }
    .preferredColorScheme(.dark)
}
