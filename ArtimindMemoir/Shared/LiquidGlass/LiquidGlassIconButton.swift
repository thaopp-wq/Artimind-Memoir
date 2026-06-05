import SwiftUI

struct LiquidGlassIconButton: View {
    let icon: String
    let title: String?
    var iconFont: Font = .title2
    var titleFont: Font = .caption
    var foregroundColor: Color = .white
    var backgroundColor: Color = .clear
    var backgroundOpacity: Double = 1.0
    var shape: ShapeType = .rounded(14)
    var size: CGFloat? = nil
    var enableBorder: Bool = false
    var borderColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: title != nil ? 4 : 0) {
                Image(systemName: icon)
                    .font(iconFont)

                if let title {
                    Text(title)
                        .font(titleFont)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(width: size, height: size)
            .frame(maxWidth: size == nil ? .infinity : nil)
            .padding(.vertical, size == nil ? 12 : 0)
            .glassBackground(
                backgroundColor: backgroundColor,
                opacity: backgroundOpacity,
                shape: shape,
                enableBorder: enableBorder,
                borderColor: borderColor,
                interactive: true
            )
        }
    }
}
