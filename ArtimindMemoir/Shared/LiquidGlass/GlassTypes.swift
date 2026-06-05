import SwiftUI

enum GlassStyle {
    case clear
    case regular
    case rounded(CGFloat)

    var cornerRadius: CGFloat {
        switch self {
        case .clear: return 0
        case .regular: return 16
        case .rounded(let radius): return radius
        }
    }
}

enum ShapeType {
    case circle
    case capsule
    case rounded(CGFloat)
}
