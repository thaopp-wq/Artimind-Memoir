import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
import PhotosUI

private enum VoiceMode: String, CaseIterable {
    case upload = "Upload Audio"
    case sample = "Voice Sample"
}

struct VoiceTributeAudioView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var session = VoiceTributeSession.shared
    @State private var navigateToScript = false
    @State private var showFileImporter = false
    @State private var videoPickerItem: PhotosPickerItem?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var mode: VoiceMode = .upload
    @State private var previewingVoiceId: String?
    @State private var speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Add Voice", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero text
                    VStack(spacing: 8) {
                        // Hero pattern (§2)
                        (
                            Text("Do you remember\nhow they ")
                                .font(ArtimindDS.Typography.heroSerif)
                                .foregroundColor(ArtimindDS.ColorToken.textPrimary)
                            +
                            Text("sounded?")
                                .font(ArtimindDS.Typography.heroItalic)
                                .foregroundColor(ArtimindDS.ColorToken.textSecondary)
                        )
                        .multilineTextAlignment(.center)

                    }

                    // Toggle inline
                    if !session.isRecording && session.audioURL == nil && !session.isExtractingAudio {
                        modeToggle
                    }

                    // Content based on state
                    if session.isRecording {
                        recordingCard
                    } else if session.audioURL != nil {
                        audioLoadedCard
                    } else if session.isExtractingAudio {
                        extractingCard
                    } else if mode == .upload {
                        uploadContent

                        // Fallback link — left aligned
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                mode = .sample
                            }
                        } label: {
                            (
                                Text("Don\u{2019}t have a recording? ")
                                    .foregroundColor(ArtimindDS.ColorToken.textTertiary)
                                +
                                Text("Choose a voice sample")
                                    .foregroundColor(ArtimindDS.ColorToken.blue)
                            )
                            .font(AppFont.dmSans(.medium, size: 13))
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        voiceSampleContent
                    }
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }

            // Bottom buttons fixed
            bottomButtons
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $navigateToScript) {
            VoiceTributeScriptView()
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.audio, .mpeg4Audio, .mp3, .wav, .movie, .mpeg4Movie, .quickTimeMovie],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .onChange(of: videoPickerItem) {
            handleVideoPickerItem()
        }
    }

    // MARK: - Mode Toggle

    private var modeToggle: some View {
        GeometryReader { geo in
            let tabWidth = (geo.size.width - 8) / 2
            let offsetX = mode == .upload ? CGFloat(4) : tabWidth + 4

            ZStack(alignment: .leading) {
                // Sliding indicator
                Capsule()
                    .fill(.white.opacity(0.18))
                    .overlay(
                        Capsule().stroke(.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .shadow(color: .white.opacity(0.06), radius: 4, y: 0)
                    .frame(width: tabWidth, height: 38)
                    .offset(x: offsetX)

                // Tabs
                HStack(spacing: 0) {
                    ForEach(VoiceMode.allCases, id: \.self) { m in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                mode = m
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: m == .upload ? "waveform" : "waveform.circle")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(m.rawValue)
                                    .font(AppFont.dmSans(.semibold, size: 13))
                            }
                            .foregroundStyle(mode == m ? .white : .white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(height: 46)
        .background(
            Capsule().fill(Color.black.opacity(0.5))
        )
        .overlay(
            Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(Capsule())
        .gesture(
            DragGesture(minimumDistance: 10)
                .onEnded { value in
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        mode = value.translation.width > 20 ? .sample : (value.translation.width < -20 ? .upload : mode)
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
        )
        .padding(.horizontal, ArtimindDS.Size.sidePadding)
    }

    // MARK: - Upload Content

    private var uploadContent: some View {
        VStack(spacing: 12) {
                // Upload options — stacked rows
                VStack(spacing: 10) {
                    Button { showFileImporter = true } label: {
                        uploadRow(
                            icon: "waveform",
                            title: "Upload Audio",
                            subtitle: "WAV or MP3 from your device",
                            iconColor: ArtimindDS.ColorToken.yellow
                        )
                    }
                    .buttonStyle(.plain)

                    PhotosPicker(selection: $videoPickerItem, matching: .videos) {
                        uploadRow(
                            icon: "film",
                            title: "Use a voice from video",
                            subtitle: "We\u{2019}ll extract the audio track",
                            iconColor: ArtimindDS.ColorToken.blue
                        )
                    }
                    .buttonStyle(.plain)
                }
        }
    }

    private func uploadRow(icon: String, title: String, subtitle: String, iconColor: Color) -> some View {
        HStack(spacing: 14) {
            // Icon left
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                )

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.dmSans(.semibold, size: 15))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(AppFont.dmSans(.regular, size: 11))
                    .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
            }

            Spacer()

            // Arrow
            Image(systemName: "arrow.up.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle().fill(Color.white.opacity(0.1))
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    private var audioLoadedCard: some View {
        VStack(spacing: ArtimindDS.Spacing.sm) {
            VStack(alignment: .leading, spacing: ArtimindDS.Spacing.xs) {
                // File info
                HStack(spacing: ArtimindDS.Spacing.xs) {
                    Text(session.audioURL?.lastPathComponent ?? "Recording")
                        .font(AppFont.dmSans(.medium, size: 13))
                        .foregroundStyle(ArtimindDS.ColorToken.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                        .onTapGesture {
                            stopPlayback()
                            session.removeAudio()
                        }
                }

                // Format + status
                HStack(spacing: ArtimindDS.Spacing.xs) {
                    Text("M4A")
                        .font(ArtimindDS.Typography.bodySmall)
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)

                    Circle()
                        .fill(ArtimindDS.ColorToken.textTertiary)
                        .frame(width: 3, height: 3)

                    Text("ready")
                        .font(ArtimindDS.Typography.bodySmall)
                        .foregroundStyle(ArtimindDS.ColorToken.sage)
                }

                // Waveform + play
                HStack(spacing: ArtimindDS.Spacing.sm) {
                    Button { togglePlayback() } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    // Waveform bars
                    AudioWaveformStatic()
                        .frame(height: 32)
                }
                .padding(.top, ArtimindDS.Spacing.xxs)

                // Playback time + Replace
                HStack {
                    Text("00:00 / 00:23")
                        .font(ArtimindDS.Typography.bodySmall)
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                        .monospacedDigit()

                    Spacer()

                    Button {
                        stopPlayback()
                        session.removeAudio()
                    } label: {
                        Text("Replace")
                            .font(AppFont.dmSans(.medium, size: 13))
                            .foregroundStyle(ArtimindDS.ColorToken.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(ArtimindDS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                    .fill(ArtimindDS.ColorToken.panelElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                    .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
            )
        }
    }

    @State private var waveformBars: [CGFloat] = []

    private var recordingCard: some View {
        VStack(spacing: 0) {
            // Bar waveform — fills from center outward
            Canvas { context, size in
                let barWidth: CGFloat = 2.5
                let barSpacing: CGFloat = 1.5
                let maxBars = Int(size.width / (barWidth + barSpacing))
                let midY = size.height / 2
                let count = waveformBars.count

                for i in 0..<maxBars {
                    let dataIndex = count - maxBars + i

                    if dataIndex >= 0 && dataIndex < count {
                        // Recorded bar — symmetric around center line
                        let level = waveformBars[dataIndex]
                        let h = max(3, level * size.height * 0.9)
                        let x = CGFloat(i) * (barWidth + barSpacing)
                        let rect = CGRect(x: x, y: midY - h / 2, width: barWidth, height: h)
                        let path = Path(roundedRect: rect, cornerRadius: 1)
                        context.fill(path, with: .color(.white))
                    } else {
                        // Empty placeholder — thin line at center
                        let x = CGFloat(i) * (barWidth + barSpacing)
                        let rect = CGRect(x: x, y: midY - 1, width: barWidth, height: 2)
                        let path = Path(roundedRect: rect, cornerRadius: 0.5)
                        context.fill(path, with: .color(.white.opacity(0.08)))
                    }
                }
            }
            .frame(height: 70)
            .padding(.horizontal, ArtimindDS.Spacing.sm)
            .padding(.top, ArtimindDS.Spacing.lg)
            .onChange(of: session.audioLevel) {
                let newBar = session.audioLevel * 0.6 + CGFloat.random(in: 0.15...0.45)
                waveformBars.append(newBar)
            }
            .onChange(of: session.isRecording) {
                if session.isRecording {
                    waveformBars = []
                }
            }

            // Timer
            Text(formatDurationLong(session.recordingDuration))
                .font(AppFont.dmSans(.bold, size: 40))
                .foregroundStyle(.white)
                .monospacedDigit()
                .padding(.top, ArtimindDS.Spacing.lg)

            Text("Recording...")
                .font(ArtimindDS.Typography.bodySmall)
                .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                .padding(.top, ArtimindDS.Spacing.xxs)

            Spacer().frame(height: ArtimindDS.Spacing.xl)

            // Bottom controls: Discard — Stop — Save
            HStack(spacing: 0) {
                // Discard
                Button {
                    session.stopRecording()
                    session.removeAudio()
                } label: {
                    VStack(spacing: ArtimindDS.Spacing.xxs) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(ArtimindDS.ColorToken.panelElevated))
                        Text("Discard")
                            .font(ArtimindDS.Typography.bodySmall)
                            .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                // Stop (pause style)
                Button { session.stopRecording() } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(Circle().fill(ArtimindDS.ColorToken.blue))
                }
                .buttonStyle(.plain)

                Spacer()

                // Save
                Button { session.stopRecording() } label: {
                    VStack(spacing: ArtimindDS.Spacing.xxs) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(ArtimindDS.ColorToken.panelElevated))
                        Text("Save")
                            .font(ArtimindDS.Typography.bodySmall)
                            .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, ArtimindDS.Spacing.xl)
            .padding(.bottom, ArtimindDS.Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    private func formatDurationLong(_ time: TimeInterval) -> String {
        let hrs = Int(time) / 3600
        let mins = (Int(time) % 3600) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }

    private var extractingCard: some View {
        HStack(spacing: 12) {
            ProgressView().tint(ArtimindDS.ColorToken.yellow)
            Text("Extracting audio...")
                .font(AppFont.dmSans(.medium, size: 14))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                .fill(ArtimindDS.ColorToken.panelElevated)
        )
    }

    // MARK: - Voice Sample Content (inline gallery)

    @State private var selectedRelation: String = "Grandmom"
    private let relations = ["Grandmom", "Grandpa", "Dad", "Mom", "Uncle", "Auntie"]

    private var voiceSampleContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Relationship chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(relations, id: \.self) { rel in
                        Button {
                            selectedRelation = rel
                        } label: {
                            Text(rel)
                                .font(AppFont.dmSans(.semibold, size: 13))
                                .foregroundStyle(selectedRelation == rel ? .white : ArtimindDS.ColorToken.textSecondary)
                                .padding(.horizontal, 16)
                                .frame(height: 34)
                                .background(
                                    Capsule().fill(selectedRelation == rel ? ArtimindDS.ColorToken.blue : ArtimindDS.ColorToken.panelElevated)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Voice list
            VStack(spacing: 6) {
                ForEach(VoiceTributeSession.defaultVoices) { voice in
                    let isSelected = session.selectedVoiceTone?.id == voice.id
                    let isPreviewing = previewingVoiceId == voice.id

                    Button {
                        session.selectedVoiceTone = voice
                    } label: {
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(voice.name)
                                    .font(AppFont.dmSans(.semibold, size: 15))
                                    .foregroundStyle(.white)
                                Text(voice.description)
                                    .font(AppFont.dmSans(.regular, size: 12))
                                    .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                            }

                            Spacer()

                            Button { previewVoice(voice) } label: {
                                Image(systemName: isPreviewing ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(isSelected ? ArtimindDS.ColorToken.blue : .white)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                                .fill(isSelected ? ArtimindDS.ColorToken.blue.opacity(0.12) : ArtimindDS.ColorToken.panel)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                                .stroke(isSelected ? ArtimindDS.ColorToken.blue.opacity(0.3) : ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        VStack(spacing: 10) {
            // Start Recording — outlined (§6.4)
            Button(action: {
                session.startRecording()
            }) {
                Text("Start Recording")
                    .font(ArtimindDS.Typography.button)
                    .foregroundStyle(ArtimindDS.ColorToken.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentShape(Rectangle())
            }
            .background(
                Capsule().stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
            )

            // Continue — white pill primary (§6.3)
            Button { navigateToScript = true } label: {
                Text("Continue")
                    .font(ArtimindDS.Typography.button)
                    .foregroundStyle(session.hasAudio ? ArtimindDS.ColorToken.blackText : AppColor.disabledButtonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        Capsule().fill(session.hasAudio ? ArtimindDS.ColorToken.whiteButton : AppColor.disabledButton)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!session.hasAudio)
        }
        .padding(.horizontal, ArtimindDS.Size.sidePadding)
        .padding(.bottom, 32)
    }

    // MARK: - Voice Preview

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
        speechSynthesizer.speak(utterance)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if previewingVoiceId == voice.id { previewingVoiceId = nil }
        }
    }

    // MARK: - Helpers

    private func formatDuration(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        let ext = url.pathExtension.lowercased()
        let dest = FileManager.default.temporaryDirectory
            .appendingPathComponent("tribute_file_\(UUID().uuidString).\(ext)")
        try? FileManager.default.copyItem(at: url, to: dest)
        let videoExts: Set<String> = ["mp4", "mov", "m4v", "avi"]
        if videoExts.contains(ext) { session.extractAudioFromVideo(dest) }
        else { session.audioURL = dest }
    }

    private func handleVideoPickerItem() {
        guard let item = videoPickerItem else { return }
        session.isExtractingAudio = true
        item.loadTransferable(type: TributeVideoTransferable.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let video):
                    if let video { session.extractAudioFromVideo(video.url) }
                    else { session.isExtractingAudio = false }
                case .failure: session.isExtractingAudio = false
                }
                videoPickerItem = nil
            }
        }
    }

    private func togglePlayback() {
        if isPlaying { stopPlayback() }
        else {
            guard let url = session.audioURL else { return }
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
        }
    }

    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}

// MARK: - Static Waveform

private struct AudioWaveformStatic: View {
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<40, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 2, height: max(3, 4 + (1 - abs(CGFloat(i) - 20) / 20) * 20 + CGFloat.random(in: -3...3)))
            }
        }
    }
}

// MARK: - Audio Waveform View

struct AudioWaveformView: View {
    let level: CGFloat
    private let barCount = 30

    var body: some View {
        HStack(spacing: 2.5) {
            ForEach(0..<barCount, id: \.self) { i in
                let distance = abs(CGFloat(i) - CGFloat(barCount) / 2) / (CGFloat(barCount) / 2)
                let height: CGFloat = 0.1 + (1 - distance) * level * 0.9 + CGFloat.random(in: 0...0.08)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(level > 0.7 ? .red : (level > 0.4 ? ArtimindDS.ColorToken.yellow : ArtimindDS.ColorToken.yellow.opacity(0.6)))
                    .frame(width: 3, height: max(4, height * 48))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Video Transferable

struct TributeVideoTransferable: Transferable {
    let url: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let dest = FileManager.default.temporaryDirectory
                .appendingPathComponent("tribute_video_\(UUID().uuidString).mov")
            try FileManager.default.copyItem(at: received.file, to: dest)
            return Self(url: dest)
        }
    }
}

#Preview {
    NavigationStack {
        VoiceTributeAudioView()
    }
    .preferredColorScheme(.dark)
}
