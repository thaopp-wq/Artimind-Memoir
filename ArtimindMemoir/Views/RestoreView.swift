import SwiftUI
import AVFoundation
import PhotosUI
import Photos

// MARK: - Feature model

private struct RestoreFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let badge: FeatureBadge
}

private enum FeatureBadge {
    case freeTry
    case comingSoonPro
    case comingSoonFree
}

private let features: [RestoreFeature] = [
    .init(
        icon: "wand.and.stars",
        title: "AI Photo Restore",
        description: "Fix scratches, colorize black-and-white, sharpen blurry faces.",
        badge: .freeTry
    ),
    .init(
        icon: "mic",
        title: "AI Voice Tribute",
        description: "Turn photos and a voice clip into a heartfelt wedding speech video.",
        badge: .comingSoonPro
    ),
    .init(
        icon: "pencil.and.outline",
        title: "AI Text Edit \u{2014} Photo",
        description: "Describe a change in words and watch it happen instantly.",
        badge: .comingSoonPro
    ),
    .init(
        icon: "film.stack",
        title: "AI Video Restore",
        description: "Upscale, colorize, and stabilize shaky footage into cinema-quality memories.",
        badge: .comingSoonPro
    ),
    .init(
        icon: "paintbrush",
        title: "AI Colorize",
        description: "Add natural color to black-and-white family photos.",
        badge: .comingSoonFree
    ),
    .init(
        icon: "face.smiling",
        title: "Face Enhance",
        description: "Recover lost detail in faces from photos taken before the digital era.",
        badge: .comingSoonPro
    ),
]

// MARK: - RestoreView

struct RestoreView: View {
    @Binding var selectedTab: Int
    @ObservedObject private var store = PeopleStore.shared
    @State private var selectedPerson: Person?
    @State private var showPeopleList = false
    @State private var hasPhotoPermission = false
    @State private var permissionDenied = false
    @State private var permissionChecked = false
    @State private var showPhotoRestore = false
    @State private var showVoiceTribute = false
    @State private var showColorize = false
    @State private var showFaceEnhance = false
    @State private var showVideoRestore = false
    @State private var showTextEdit = false
    @State private var textEditImage: UIImage?
    @State private var navigateToTextEdit = false
    @State private var restoreImage: UIImage?
    @State private var navigateToRestore = false
    @State private var colorizeImage: UIImage?
    @State private var navigateToColorize = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero video banner
                heroBanner

                // Features section
                featuresSection
                    .padding(.top, 16)

                // People section
                peopleSection
                    .padding(.top, 24)

                Spacer()
                    .frame(height: 120)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) {
            GlassBackButton(action: { selectedTab = 0 })
                .padding(.leading, ArtimindDS.Size.sidePadding)
                .padding(.top, 10)
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedPerson) { person in
            PersonTimelineView(person: person)
        }
        .navigationDestination(isPresented: $showPhotoRestore) {
            PhotoPickerView(
                title: "Photo Restore",
                subtitle: "Choose a photo to restore"
            ) { img in
                restoreImage = img
                navigateToRestore = true
            }
        }
        .navigationDestination(isPresented: $navigateToRestore) {
            if let img = restoreImage {
                PhotoRestoreProcessingView(image: img)
            }
        }
        .navigationDestination(isPresented: $showColorize) {
            PhotoPickerView(
                title: "Colorize",
                subtitle: "Choose a black-and-white photo to colorize"
            ) { img in
                colorizeImage = img
                navigateToColorize = true
            }
        }
        .navigationDestination(isPresented: $navigateToColorize) {
            if let img = colorizeImage {
                PhotoRestoreProcessingView(image: img, isColorize: true)
            }
        }
        .navigationDestination(isPresented: $showVoiceTribute) {
            VoiceTributePhotoView()
        }
        .navigationDestination(isPresented: $showTextEdit) {
            PhotoPickerView(
                title: "Text Edit",
                subtitle: "Choose a photo to edit with AI"
            ) { img in
                textEditImage = img
                navigateToTextEdit = true
            }
        }
        .navigationDestination(isPresented: $navigateToTextEdit) {
            if let img = textEditImage {
                TextEditPhotoView(image: img)
            }
        }
    }

    // MARK: - Hero Banner

    private var heroBanner: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Video/image background with gradient + text overlay
            ZStack(alignment: .bottomLeading) {
                // Background layer
                Color.black

                // Fallback image
                Image("explore-restore")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 360)
                    .clipped()
                    .allowsHitTesting(false)

                // Video (on top of image, below gradient)
                if let url = Bundle.main.url(forResource: "restore-hero", withExtension: "mov") {
                    RestoreHeroVideo(url: url)
                        .allowsHitTesting(false)
                }

                // Gradient — must be above video
                LinearGradient(
                    colors: [
                        .clear,
                        .clear,
                        ArtimindDS.ColorToken.appBackground.opacity(0.3),
                        ArtimindDS.ColorToken.appBackground.opacity(0.6),
                        ArtimindDS.ColorToken.appBackground.opacity(0.85),
                        ArtimindDS.ColorToken.appBackground,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                // Text overlay
                VStack(alignment: .leading, spacing: ArtimindDS.Spacing.xs) {
                    (
                        Text("Heal what time\nhas ")
                            .font(ArtimindDS.Typography.heroSerif)
                            .foregroundColor(ArtimindDS.ColorToken.textPrimary)
                        +
                        Text("touched.")
                            .font(ArtimindDS.Typography.heroItalic)
                            .foregroundColor(ArtimindDS.ColorToken.textSecondary)
                    )
                    .lineSpacing(2)

                    Text("Faded photos, damaged memories, blurry faces \u{2014}\ngive them the care they deserve.")
                        .font(ArtimindDS.Typography.body)
                        .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                        .lineSpacing(2)
                }
                .padding(ArtimindDS.Spacing.lg)
            }
            .frame(height: 360)
            .clipped()
        }
    }

    // MARK: - Features Section

    private struct FeatureInfo {
        let icon: String
        let title: String
        let subtitle: String
        let badges: [(text: String, style: BadgeStyle)]
        let action: String

        enum BadgeStyle {
            case outline  // "Free To Try"
            case pro      // "Pro" yellow
            case launched // "Just Launched" white
        }
    }

    private let featureList: [FeatureInfo] = [
        .init(icon: "\u{1F5BC}\u{FE0F}", title: "AI Photo Restore",
              subtitle: "Fix scratches, sharpen blurry faces.",
              badges: [],
              action: "Photo Restore"),
        .init(icon: "\u{270F}\u{FE0F}", title: "AI Text Edit",
              subtitle: "Describe a change, watch it happen.",
              badges: [],
              action: "Text Edit"),
        .init(icon: "\u{1F399}\u{FE0F}", title: "AI Voice Tribute",
              subtitle: "Create a heartfelt\nvoice message.",
              badges: [],
              action: "Voice Tribute"),
        .init(icon: "\u{1F3A8}", title: "AI Colorize",
              subtitle: "Add color to black-and-white photos.",
              badges: [],
              action: "Colorize"),
    ]

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: ArtimindDS.Spacing.sm) {
            Text("Explore Memory Restoration")
                .font(AppFont.dmSans(.medium, size: 14))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .padding(.horizontal, ArtimindDS.Size.sidePadding)

            let columns = [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
            ]
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(featureList, id: \.title) { feature in
                    Button {
                        switch feature.action {
                        case "Photo Restore": showPhotoRestore = true
                        case "Colorize": showColorize = true
                        case "Text Edit": showTextEdit = true
                        case "Voice Tribute": showVoiceTribute = true
                        default: break
                        }
                    } label: {
                        featureCard(feature)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, ArtimindDS.Size.sidePadding)
        }
    }

    private func featureCard(_ feature: FeatureInfo) -> some View {
        HStack {
            Text(feature.title)
                .font(AppFont.dmSans(.bold, size: 14))
                .foregroundStyle(.white)

            Spacer()

            Text(feature.icon)
                .font(.system(size: 24))
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - People Section

    private var peopleSection: some View {
        VStack(alignment: .leading, spacing: ArtimindDS.Spacing.sm) {
            // Section header (§6.1)
            HStack {
                Button { showPeopleList = true } label: {
                    HStack(spacing: ArtimindDS.Spacing.xxs) {
                        Text("Choose Loved Ones to heal their photos")
                            .font(AppFont.dmSans(.medium, size: 14))
                            .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, ArtimindDS.Size.sidePadding)
            .navigationDestination(isPresented: $showPeopleList) {
                PeopleListView()
            }

            if !permissionChecked || hasPhotoPermission {
                // Vertical grid of people cards
                let columns = [
                    GridItem(.flexible(), spacing: 24),
                    GridItem(.flexible(), spacing: 24),
                ]
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(store.people.prefix(8)) { person in
                        Button { selectedPerson = person } label: {
                            PersonCard(person: person)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)

                // Add Person button
                Button { showPeopleList = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(ArtimindDS.ColorToken.blue)
                        Text("Add Person")
                            .font(AppFont.dmSans(.semibold, size: 14))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                        .strokeBorder(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, ArtimindDS.Size.sidePadding)
            } else {
                // Empty state — no photo permission
                VStack(spacing: 14) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)

                    if permissionDenied {
                        Text("Photo access was denied.\nGo to Settings to allow access.")
                            .font(AppFont.dmSans(.regular, size: 13))
                            .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                            .multilineTextAlignment(.center)

                        Button { openSettings() } label: {
                            Text("Open Settings")
                                .font(AppFont.dmSans(.bold, size: 14))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 24)
                                .frame(height: 40)
                                .background(Capsule().fill(.white))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Allow photo access to find\nyour loved ones automatically")
                            .font(AppFont.dmSans(.regular, size: 13))
                            .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                            .multilineTextAlignment(.center)

                        Button { requestPhotoPermission() } label: {
                            Text("Allow Access")
                                .font(AppFont.dmSans(.bold, size: 14))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 24)
                                .frame(height: 40)
                                .background(Capsule().fill(.white))
                        }
                        .buttonStyle(.plain)
                    }

                    Button { showPeopleList = true } label: {
                        Text("Add manually instead")
                            .font(AppFont.dmSans(.medium, size: 13))
                            .foregroundStyle(ArtimindDS.ColorToken.blue)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
            }
        }
        .onAppear { checkPhotoPermission() }
    }

    private func checkPhotoPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        permissionChecked = true
        hasPhotoPermission = (status == .authorized || status == .limited)
        permissionDenied = (status == .denied || status == .restricted)
    }

    private func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                hasPhotoPermission = (status == .authorized || status == .limited)
                permissionDenied = (status == .denied || status == .restricted)
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - People model & data

struct Person: Identifiable, Hashable {
    let id: UUID
    var name: String
    let imageName: String

    var isUnnamed: Bool { name.isEmpty }

    init(name: String = "", imageName: String) {
        self.id = UUID()
        self.name = name
        self.imageName = imageName
    }
}

let samplePeople: [Person] = [
    .init(name: "Grandpa", imageName: "avatar-man"),
    .init(name: "", imageName: "avatar-woman"),
    .init(name: "Dad", imageName: "explore-restore"),
    .init(name: "", imageName: "explore-loved-ones"),
    .init(name: "Uncle", imageName: "hero-memory"),
    .init(name: "", imageName: "explore-living-album"),
    .init(name: "Brother", imageName: "avatar-man"),
    .init(name: "", imageName: "avatar-woman"),
    .init(name: "Cousin", imageName: "explore-restore"),
    .init(name: "", imageName: "explore-loved-ones"),
    .init(name: "Nephew", imageName: "hero-memory"),
    .init(name: "", imageName: "explore-living-album"),
    .init(name: "Neighbor", imageName: "avatar-man"),
    .init(name: "", imageName: "avatar-woman"),
    .init(name: "Coach", imageName: "hero-memory"),
]

// MARK: - Person card

private struct PersonCard: View {
    let person: Person

    var body: some View {
        VStack(spacing: 8) {
            Image(person.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                )

            if person.isUnnamed {
                HStack(spacing: 4) {
                    Image(systemName: "pencil")
                        .font(.system(size: 10, weight: .medium))
                    Text("Name")
                        .font(AppFont.dmSans(.regular, size: 12))
                }
                .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
            } else {
                Text(person.name)
                    .font(AppFont.dmSans(.semibold, size: 13))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Feature card

private struct RestoreFeatureCard: View {
    let feature: RestoreFeature

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: feature.icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(ArtimindDS.ColorToken.yellow)
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .fill(ArtimindDS.ColorToken.panel)
                )
                .overlay(
                    Circle()
                        .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(feature.title)
                    .font(AppFont.dmSans(.semibold, size: 16))
                    .foregroundStyle(ArtimindDS.ColorToken.textPrimary)

                Text(feature.description)
                    .font(AppFont.dmSans(.regular, size: 13))
                    .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)

                badgeRow
                    .padding(.top, 2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var badgeRow: some View {
        switch feature.badge {
        case .freeTry:
            FreeBadge()
        case .comingSoonPro:
            HStack(spacing: 8) {
                ComingSoonBadge()
                ProBadge()
            }
        case .comingSoonFree:
            HStack(spacing: 8) {
                ComingSoonBadge()
                FreeBadge()
            }
        }
    }
}

// MARK: - Badge components

private struct ComingSoonBadge: View {
    var body: some View {
        Text("Coming Soon")
            .font(AppFont.dmSans(.medium, size: 12))
            .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(ArtimindDS.ColorToken.panelElevated)
            )
    }
}

private struct ProBadge: View {
    var body: some View {
        Text("Pro")
            .font(AppFont.dmSans(.bold, size: 12))
            .foregroundStyle(.black)
            .padding(.horizontal, 14)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(ArtimindDS.ColorToken.yellow)
            )
    }
}

private struct FreeBadge: View {
    var body: some View {
        Text("Free To Try")
            .font(AppFont.dmSans(.medium, size: 12))
            .foregroundStyle(ArtimindDS.ColorToken.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .stroke(ArtimindDS.ColorToken.stroke, lineWidth: 1)
            )
    }
}

// MARK: - Restore Hero Video

private struct RestoreHeroVideo: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> RestoreHeroVideoUIView {
        RestoreHeroVideoUIView(url: url)
    }

    func updateUIView(_ uiView: RestoreHeroVideoUIView, context: Context) {}
}

private class RestoreHeroVideoUIView: UIView {
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?

    init(url: URL) {
        super.init(frame: .zero)
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(items: [item])
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        queuePlayer.isMuted = true
        player = queuePlayer

        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        queuePlayer.play()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let playerLayer = layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = bounds
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RestoreView(selectedTab: .constant(2))
    }
    .preferredColorScheme(.dark)
}
