import SwiftUI

// MARK: - Legacy tokens (kept for backward compat with existing views)

enum AppColor {
    static let background = ArtimindDS.ColorToken.appBackground
    static let backgroundSecondary = ArtimindDS.ColorToken.panel
    static let backgroundTertiary = ArtimindDS.ColorToken.panelElevated
    static let brandMain = Color(hex: "#A60816")
    static let brandBright = Color(hex: "#F2333F")
    static let laser = Color(hex: "#C9A96E")
    static let pewter = Color(hex: "#8FA89A")
    static let labelPrimary = ArtimindDS.ColorToken.textPrimary
    static let labelSecondary = ArtimindDS.ColorToken.textSecondary
    static let labelTertiary = ArtimindDS.ColorToken.textTertiary
    static let tabActive = ArtimindDS.ColorToken.blue
    static let tabInactive = ArtimindDS.ColorToken.tabInactive
    static let cardBorder = ArtimindDS.ColorToken.strokeSoft
    static let inputBackground = ArtimindDS.ColorToken.panel
    static let requiredLabel = Color(hex: "#F26B8C")
    static let proGold = ArtimindDS.ColorToken.yellow
    static let disabledButton = Color(hex: "#29292B")
    static let disabledButtonText = Color(hex: "#737378")
    static let success = Color(hex: "#33B259")
}

enum AppFont {
    static func cormorant(_ weight: Font.Weight = .bold, size: CGFloat) -> Font {
        switch weight {
        case .semibold:
            return .custom("CormorantGaramond-SemiBold", size: size)
        case .bold:
            return .custom("CormorantGaramond-Bold", size: size)
        case .medium:
            return .custom("CormorantGaramond-Medium", size: size)
        default:
            return .custom("CormorantGaramond-Regular", size: size)
        }
    }

    static func dmSans(_ weight: Font.Weight = .regular, size: CGFloat) -> Font {
        switch weight {
        case .semibold:
            return .custom("DMSans-SemiBold", size: size)
        case .medium:
            return .custom("DMSans-Medium", size: size)
        case .bold:
            return .custom("DMSans-Bold", size: size)
        default:
            return .custom("DMSans-Regular", size: size)
        }
    }
}

enum AppSpacing {
    static let screenPadding: CGFloat = ArtimindDS.Size.sidePadding
    static let cardRadius: CGFloat = ArtimindDS.Radius.lg
    static let pillRadius: CGFloat = ArtimindDS.Radius.pill
    static let itemGap: CGFloat = ArtimindDS.Spacing.sm
    static let smallGap: CGFloat = ArtimindDS.Spacing.xs
}

// MARK: - Artimind Design System (Figma)

enum ArtimindDS {
    enum ColorToken {
        static let appBackground = Color(hex: "#141419")
        static let panel = Color(hex: "#242426")
        static let panelElevated = Color(hex: "#2E2E30")
        static let panelPressed = Color(hex: "#383839")
        static let stroke = Color(hex: "#5C5C5C")
        static let strokeSoft = Color.white.opacity(0.10)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.68)
        static let textTertiary = Color.white.opacity(0.46)
        static let tabInactive = Color.white.opacity(0.84)
        static let yellow = Color(red: 1.00, green: 0.82, blue: 0.22)
        static let amber = Color(hex: "#C9A96E")
        static let yellowDark = Color(red: 0.30, green: 0.24, blue: 0.14)
        static let blue = Color(red: 0.00, green: 0.56, blue: 1.00)
        static let sage = Color(hex: "#8FA89A")
        static let greenSoft = Color(red: 0.22, green: 0.31, blue: 0.28)
        static let whiteButton = Color.white
        static let blackText = Color(red: 0.05, green: 0.05, blue: 0.06)
    }

    enum Typography {
        static let brand = Font.custom("CormorantGaramond-SemiBold", size: 27)
        static let heroSerif = Font.custom("CormorantGaramond-Bold", size: 31)
        static let heroItalic = Font.custom("CormorantGaramond-Regular", size: 30).italic()
        static let title = Font.custom("DMSans-SemiBold", size: 17)
        static let body = Font.custom("DMSans-Regular", size: 13)
        static let bodySmall = Font.custom("DMSans-Regular", size: 12)
        static let eyebrow = Font.custom("DMSans-Medium", size: 8)
        static let button = Font.custom("DMSans-Bold", size: 15)
        static let tab = Font.custom("DMSans-Medium", size: 8)
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 18
        static let xl: CGFloat = 28
        static let pill: CGFloat = 999
    }

    enum Size {
        static let sidePadding: CGFloat = 16
        static let cardHeight: CGFloat = 144
        static let tabBarHeight: CGFloat = 58
        static let avatarSize: CGFloat = 73
    }
}

// MARK: - Color hex init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
