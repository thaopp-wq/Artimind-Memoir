import SwiftUI

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 16
    let content: () -> Content

    init(padding: CGFloat = 16, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackground(shape: .rounded(20))
    }
}
