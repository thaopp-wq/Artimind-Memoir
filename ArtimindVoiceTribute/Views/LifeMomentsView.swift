import SwiftUI

struct LifeMomentsView: View {
    @Binding var selectedTab: Int
    @State private var selectedSegment = 0
    @State private var selectedWeddingTemplate: WeddingTemplate?
    @State private var openPendingResult = false
    @State private var isCardMuted = true

    private let segments = ["Wedding", "Grandmom", "Grandpa", "Mommy", "Papa", "Family"]

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Life Moments", onBack: { selectedTab = 0 })
                .padding(.top, 8)

            segmentedControl
                .padding(.top, 12)
                .padding(.bottom, 10)

            weddingPager
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedWeddingTemplate) { _ in
            WeddingUploadPhotosView()
        }
        .navigationDestination(isPresented: $openPendingResult) {
            ResultView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .popWeddingFlow)) { _ in
            selectedWeddingTemplate = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .openPendingResult)) { _ in
            openPendingResult = true
        }
    }

    // MARK: - Wedding Pager (vertical paging, full-height cards)

    private var weddingPager: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(WeddingTemplate.samples) { template in
                        weddingPage(template)
                            .frame(height: proxy.size.height)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
        }
    }

    private func weddingPage(_ template: WeddingTemplate) -> some View {
        VStack(spacing: 0) {
            weddingCard(template)
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 12)
        }
    }

    private func weddingCard(_ template: WeddingTemplate) -> some View {
        ZStack {
            Color.black

            // Background image
            if !template.thumbnail.isEmpty {
                GeometryReader { geo in
                    Image(template.thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            }

            // Bottom gradient
            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.0), Color.black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Speaker/mute icon (top-right)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isCardMuted.toggle()
                        }
                    } label: {
                        Image(systemName: isCardMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.black.opacity(0.35)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.trailing, 12)
                .padding(.top, 12)
                Spacer()
            }

            // Footer: thumbnails + title + Get Video
            VStack {
                Spacer()
                weddingCardFooter(template)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func weddingCardFooter(_ template: WeddingTemplate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Voice quote strip
            voiceQuoteStrip(for: template)

            // Title + subtitle + Get Video
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(AppFont.cormorant(.semibold, size: 22))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 1)

                    Text(speakerSubtitle(for: template))
                        .font(AppFont.dmSans(.regular, size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer(minLength: 8)

                Button {
                    WeddingTributeManager.shared.selectTemplate(template)
                    selectedWeddingTemplate = template
                } label: {
                    Text("Get Video")
                        .font(AppFont.dmSans(.bold, size: 15))
                        .foregroundColor(.black)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.white))
                        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// Translucent strip showing a script preview with waveform icon.
    private func voiceQuoteStrip(for template: WeddingTemplate) -> some View {
        let preview = scriptPreview(for: template, maxChars: 80)

        return HStack(spacing: 10) {
            // Waveform icon
            Image(systemName: "waveform")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white.opacity(0.7))

            // Script preview
            Text("\"\(preview)\"")
                .font(AppFont.cormorant(.medium, size: 15))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(2)
                .lineSpacing(2)
                .italic()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func scriptPreview(for template: WeddingTemplate, maxChars: Int) -> String {
        let speaker = template.speakerRole == .father ? "Dad" : "Mom"
        let text: String
        switch template.id {
        case "wedding_father_speech_01":
            text = "Today you begin a beautiful new chapter. Even though I can't be there, my love will always walk with you."
        case "wedding_mother_speech_01":
            text = "Today you become family, and my heart overflows with love. I wish I could hold your hand one more time."
        case "wedding_father_family_01":
            text = "If I could be there tonight, I would raise my glass to you both. Build a life full of laughter."
        default:
            text = "A heartfelt message from \(speaker), for the moment they couldn't be there."
        }
        if text.count <= maxChars { return text }
        let trimmed = String(text.prefix(maxChars))
        if let lastSpace = trimmed.lastIndex(of: " ") {
            return String(trimmed[..<lastSpace]) + "..."
        }
        return trimmed + "..."
    }

    private func speakerSubtitle(for template: WeddingTemplate) -> String {
        let speaker = template.speakerRole == .father ? "Dad" : "Mom"
        return "Voice message from \(speaker)"
    }

    private var segmentedControl: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<segments.count, id: \.self) { index in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                selectedSegment = index
                                proxy.scrollTo(index, anchor: .center)
                            }
                        } label: {
                            Text(segments[index])
                                .font(AppFont.dmSans(.semibold, size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(Color.white.opacity(index == selectedSegment ? 0.12 : 0.06))
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(
                                            Color.white.opacity(index == selectedSegment ? 0.45 : 0.10),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .id(index)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

}

#Preview {
    NavigationStack {
        LifeMomentsView(selectedTab: .constant(1))
    }
    .preferredColorScheme(.dark)
}
