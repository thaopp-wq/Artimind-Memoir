import SwiftUI

// MARK: - ArtBadge

struct ArtBadge: View {
    enum Tone {
        case yellow
        case green
        case pro
    }

    let title: String
    var tone: Tone = .yellow
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
            }
            Text(title)
                .font(.system(size: tone == .pro ? 12 : 13, weight: .bold))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, tone == .pro ? 12 : 16)
        .frame(height: tone == .pro ? 30 : 31)
        .background(Capsule(style: .continuous).fill(background))
        .shadow(color: .black.opacity(tone == .pro ? 0.45 : 0.0), radius: 10, x: 0, y: 6)
    }

    private var foreground: Color {
        switch tone {
        case .pro: return .black
        case .yellow: return ArtimindDS.ColorToken.amber
        case .green: return ArtimindDS.ColorToken.sage
        }
    }

    private var background: Color {
        switch tone {
        case .pro: return ArtimindDS.ColorToken.yellow
        case .yellow: return ArtimindDS.ColorToken.amber.opacity(0.15)
        case .green: return ArtimindDS.ColorToken.sage.opacity(0.2)
        }
    }
}

// MARK: - ArtPillButton

struct ArtPillButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ArtimindDS.Typography.button)
                .foregroundStyle(ArtimindDS.ColorToken.blackText)
                .frame(height: 43)
                .padding(.horizontal, 22)
                .background(Capsule(style: .continuous).fill(ArtimindDS.ColorToken.whiteButton))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

// MARK: - ArtLogo

struct ArtLogo: View {
    var body: some View {
        HStack(spacing: 10) {
            Image("art-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                .accessibilityHidden(true)

            Text("artimind")
                .font(ArtimindDS.Typography.brand)
                .foregroundStyle(.white)
                .kerning(0.2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("artimind")
    }
}

// MARK: - MemoryAvatar

struct MemoryAvatar: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 58, height: 73)
            .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous)
                    .stroke(.white, lineWidth: 1)
            )
    }
}

// MARK: - PageIndicator

struct PageIndicator: View {
    let activeIndex: Int
    let count: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == activeIndex ? Color.white : Color.white.opacity(0.48))
                    .frame(width: index == activeIndex ? 20 : 4, height: 4)
            }
        }
        .accessibilityLabel("Page \(activeIndex + 1) of \(count)")
    }
}

// MARK: - HeroMemoryCard

struct HeroMemoryCard: View {
    var onGetVideo: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("hero-memory")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 472)
                .clipped()

            LinearGradient(
                stops: [
                    .init(color: ArtimindDS.ColorToken.appBackground, location: 0.0),
                    .init(color: ArtimindDS.ColorToken.appBackground.opacity(0.0), location: 0.26),
                    .init(color: ArtimindDS.ColorToken.appBackground.opacity(0.0), location: 0.61),
                    .init(color: ArtimindDS.ColorToken.appBackground, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 472)

            VStack(spacing: 18) {
                HStack(alignment: .bottom, spacing: 10) {
                    HStack(spacing: 12) {
                        MemoryAvatar(imageName: "avatar-man")
                        Text("+")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(.white)
                        MemoryAvatar(imageName: "avatar-woman")
                    }
                    Spacer()
                    ArtPillButton(title: "Get Video", action: onGetVideo)
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding + 17)

                HStack {
                    Text("Teaching baseball")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding + 17)

                PageIndicator(activeIndex: 2, count: 5)
                    .padding(.bottom, 4)
            }
            .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 472)
        .clipped()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Memory preview. Teaching baseball. Get Video.")
    }
}

// MARK: - ExploreCard

struct ExploreCard: View {
    let imageName: String
    let title: String
    let description: String
    let badge: String
    let badgeTone: ArtBadge.Tone
    let actionTitle: String
    var onTap: () -> Void = {}

    var body: some View {
        HStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 144, height: ArtimindDS.Size.cardHeight)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(ArtimindDS.Typography.title)
                    .foregroundStyle(.white)

                Text(description)
                    .font(ArtimindDS.Typography.bodySmall)
                    .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                    .lineLimit(4)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                HStack(spacing: 12) {
                    ArtBadge(title: badge, tone: badgeTone)
                    ArtPillButton(title: actionTitle, action: onTap)
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: ArtimindDS.Size.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: 17.5, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 17.5, style: .continuous)
                .stroke(ArtimindDS.ColorToken.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 17.5, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
