import SwiftUI
import AVFoundation

struct VoiceGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var session = VoiceTributeSession.shared
    @State private var previewingVoiceId: String?
    @State private var speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "AI Voices", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(VoiceTributeSession.defaultVoices) { voice in
                        voiceCard(voice)
                    }
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }

            // Select button
            if session.selectedVoiceTone != nil {
                Button {
                    speechSynthesizer.stopSpeaking(at: .immediate)
                    dismiss()
                } label: {
                    Text("Use \(session.selectedVoiceTone?.name ?? "") voice")
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
    }

    // MARK: - Voice card

    private func voiceCard(_ voice: VoiceTone) -> some View {
        let isSelected = session.selectedVoiceTone?.id == voice.id
        let isPreviewing = previewingVoiceId == voice.id

        return HStack(spacing: 14) {
            // Play preview button
            Button { previewVoice(voice) } label: {
                Image(systemName: isPreviewing ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(isSelected ? .black : ArtimindDS.ColorToken.yellow)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(voice.name)
                    .font(AppFont.dmSans(.semibold, size: 16))
                Text(voice.description)
                    .font(AppFont.dmSans(.regular, size: 12))
                    .foregroundStyle(isSelected ? Color.black.opacity(0.6) : ArtimindDS.ColorToken.textTertiary)
            }
            .foregroundStyle(isSelected ? .black : .white)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.black)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .fill(isSelected ? ArtimindDS.ColorToken.yellow : ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                .stroke(isSelected ? Color.clear : ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
        .onTapGesture {
            session.selectedVoiceTone = voice
        }
    }

    // MARK: - Preview voice

    private func previewVoice(_ voice: VoiceTone) {
        if previewingVoiceId == voice.id {
            speechSynthesizer.stopSpeaking(at: .immediate)
            previewingVoiceId = nil
            return
        }

        speechSynthesizer.stopSpeaking(at: .immediate)
        previewingVoiceId = voice.id

        let utterance = AVSpeechUtterance(string: "Hello, this is how I sound. I hope you like my voice.")
        utterance.rate = 0.48

        if voice.id.contains("female") {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.pitchMultiplier = 1.2
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            utterance.pitchMultiplier = 0.9
        }

        if voice.id.contains("elder") {
            utterance.rate = 0.42
        }

        speechSynthesizer.speak(utterance)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if previewingVoiceId == voice.id {
                previewingVoiceId = nil
            }
        }
    }
}

#Preview {
    NavigationStack {
        VoiceGalleryView()
    }
    .preferredColorScheme(.dark)
}
