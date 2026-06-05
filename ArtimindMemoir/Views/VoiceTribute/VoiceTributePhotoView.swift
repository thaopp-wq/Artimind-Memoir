import SwiftUI

struct VoiceTributePhotoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var session = VoiceTributeSession.shared
    @State private var showPicker = false
    @State private var navigateToAudio = false

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Choose Photo", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Photo slot
                    photoSlot

                    // Tips
                    tipsSection
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }

            // Continue
            if session.hasPhoto {
                Button { navigateToAudio = true } label: {
                    Text("Continue")
                        .font(AppFont.dmSans(.bold, size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Capsule().fill(AppColor.brandMain))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.bottom, 36)
            }
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $session.photo)
        }
        .navigationDestination(isPresented: $navigateToAudio) {
            VoiceTributeAudioView()
        }
    }

    // MARK: - Photo slot

    private var photoSlot: some View {
        Button { showPicker = true } label: {
            if let photo = session.photo {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous))

                    Button {
                        session.photo = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white, Color.black.opacity(0.5))
                    }
                    .padding(12)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.rectangle.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)

                    Text("Tap to select a portrait photo")
                        .font(AppFont.dmSans(.medium, size: 14))
                        .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(
                    RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                        .strokeBorder(
                            ArtimindDS.ColorToken.stroke,
                            style: StrokeStyle(lineWidth: 1, dash: [8, 5])
                        )
                )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photo tips")
                .font(AppFont.dmSans(.semibold, size: 16))
                .foregroundStyle(.white)

            tipRow(icon: "face.smiling", text: "Clear, front-facing portrait works best")
            tipRow(icon: "light.max", text: "Good lighting, no heavy shadows")
            tipRow(icon: "person.fill", text: "Only one person in the photo")
            tipRow(icon: "mouth.fill", text: "Mouth and chin should be visible")
        }
        .padding(16)
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

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(ArtimindDS.ColorToken.yellow)
                .frame(width: 22)
            Text(text)
                .font(AppFont.dmSans(.regular, size: 13))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        VoiceTributePhotoView()
    }
    .preferredColorScheme(.dark)
}
