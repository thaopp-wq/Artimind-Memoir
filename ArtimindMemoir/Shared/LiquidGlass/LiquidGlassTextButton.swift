import SwiftUI

struct LiquidGlassTextButton: View {
    let title: String
    var icon: String? = nil
    var font: Font = .subheadline
    var fontWeight: Font.Weight = .medium
    var foregroundColor: Color = .primary
    var backgroundColor: Color = .clear
    var backgroundOpacity: Double = 1.0
    var shape: ShapeType = .rounded(16)
    var enableBorder: Bool = false
    var borderColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(fontWeight)
            }
            .font(font)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(foregroundColor)
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
