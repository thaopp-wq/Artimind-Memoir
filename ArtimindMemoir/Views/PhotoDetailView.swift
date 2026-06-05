import SwiftUI
import PhotosUI

// MARK: - AI Tool model

private struct AITool: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let accent: Color
}

private let aiTools: [AITool] = [
    .init(icon: "wand.and.stars", title: "Photo Restore", subtitle: "Fix scratches, sharpen blurry faces", accent: Color(hex: "#4ECDC4")),
    .init(icon: "pencil.and.outline", title: "Text Edit", subtitle: "Describe a change, watch it happen", accent: Color(hex: "#FFD93D")),
    .init(icon: "paintbrush", title: "Colorize", subtitle: "Add natural color to old photos", accent: Color(hex: "#A78BFA")),
    .init(icon: "mic", title: "Voice Tribute", subtitle: "Create a heartfelt voice message", accent: Color(hex: "#F472B6")),
]

// MARK: - PhotoDetailView

struct PhotoDetailView: View {
    let imageName: String
    var onToolSelected: ((String, String) -> Void)?
    @Environment(\.dismiss) private var dismiss

    @State private var showRestore = false
    @State private var showColorize = false
    @State private var showTextEdit = false
    @State private var showVoiceTribute = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 0) {
                    // Top bar
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.black.opacity(0.62)))
                                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, ArtimindDS.Size.sidePadding)
                    .padding(.top, ArtimindDS.Spacing.xs)

                    Spacer()

                    // Tool grid
                    toolBar
                }
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .navigationDestination(isPresented: $showRestore) {
                if let img = UIImage(named: imageName) {
                    PhotoRestoreProcessingView(image: img)
                }
            }
            .navigationDestination(isPresented: $showColorize) {
                if let img = UIImage(named: imageName) {
                    PhotoRestoreProcessingView(image: img, isColorize: true)
                }
            }
            .navigationDestination(isPresented: $showTextEdit) {
                if let img = UIImage(named: imageName) {
                    TextEditPhotoView(image: img)
                }
            }
            .navigationDestination(isPresented: $showVoiceTribute) {
                VoiceTributePhotoView()
            }
        }
    }

    private func handleToolTap(_ tool: AITool) {
        switch tool.title {
        case "Photo Restore": showRestore = true
        case "Colorize": showColorize = true
        case "Text Edit": showTextEdit = true
        case "Voice Tribute": showVoiceTribute = true
        default: break
        }
    }

    // MARK: - Tool grid (2x2 cards)

    private let gridColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    private var toolBar: some View {
        LazyVGrid(columns: gridColumns, spacing: 10) {
            ForEach(aiTools) { tool in
                Button { handleToolTap(tool) } label: {
                    VStack(spacing: 0) {
                        HStack(alignment: .center) {
                            Text(tool.title)
                                .font(AppFont.dmSans(.bold, size: 14))
                                .foregroundStyle(.white)

                            Spacer()

                            Image(systemName: tool.icon)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(tool.accent)
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(tool.accent.opacity(0.15))
                                )
                        }

                        Spacer()

                        Text(tool.subtitle)
                            .font(AppFont.dmSans(.regular, size: 10))
                            .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .glassBackground(
                        shape: .rounded(16),
                        enableBorder: true,
                        borderColor: Color.white.opacity(0.18),
                        borderLineWidth: 0.5,
                        interactive: true
                    )
                    .shadow(color: .white.opacity(0.04), radius: 8, y: 2)
                    .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, ArtimindDS.Size.sidePadding)
        .padding(.bottom, ArtimindDS.Spacing.xl)
    }
}

#Preview {
    PhotoDetailView(imageName: "hero-memory")
        .preferredColorScheme(.dark)
}
