import SwiftUI

struct NavBarView: View {
    let title: String
    var onBack: (() -> Void)? = nil
    var trailingButton: AnyView? = nil

    var body: some View {
        ZStack {
            Text(title)
                .font(AppFont.cormorant(.semibold, size: 21))
                .foregroundColor(AppColor.labelPrimary)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                if let onBack = onBack {
                    GlassBackButton(action: onBack)
                }
                Spacer()
                if let trailing = trailingButton {
                    trailing
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .frame(height: 54)
    }
}

struct GlassBackButton: View {
    let action: () -> Void
    var tintBackground: Bool = true

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(Color.black.opacity(tintBackground ? 0.35 : 0))
                )
                .glassBackground(
                    shape: .circle,
                    enableBorder: true,
                    borderColor: Color.white.opacity(0.22),
                    borderLineWidth: 1,
                    interactive: true
                )
        }
        .buttonStyle(.plain)
    }
}

struct GlassCircleButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .glassBackground(shape: .circle, interactive: true)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        VStack {
            NavBarView(
                title: "Add Photos",
                onBack: {},
                trailingButton: AnyView(
                    GlassCircleButton(icon: "arrow.down.circle") {}
                )
            )
            Spacer()
        }
    }
    .preferredColorScheme(.dark)
}
