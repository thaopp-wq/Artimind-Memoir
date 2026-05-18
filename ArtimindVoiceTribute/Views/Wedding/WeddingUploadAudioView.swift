import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
import PhotosUI

struct WeddingUploadAudioView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = WeddingTributeManager.shared
    @State private var showAudioPicker = false
    @State private var navigateToScript = false
    @State private var isPlayingAudio = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var playbackTime: TimeInterval = 0
    @State private var playbackTimer: Timer?
    @State private var videoPickerItem: PhotosPickerItem?
    @State private var previewingToneId: String?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var audioDurationCache: TimeInterval = 0

    /// true = upload recording (default), false = voice sample
    @State private var hasRealVoice: Bool? = true

    private var speakerName: String {
        guard let t = manager.selectedTemplate else { return "Dad" }
        return t.speakerRole == .father ? "Dad" : "Mom"
    }

    private var audioDuration: TimeInterval { audioDurationCache }
    private var audioFileName: String { manager.audioFileURL?.lastPathComponent ?? "" }
    private var audioFileExtension: String { manager.audioFileURL?.pathExtension.uppercased() ?? "" }

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Choosing Voice", onBack: {
                if manager.audioFileURL != nil {
                    // Audio loaded → back to upload step
                    stopAudio()
                    manager.removeAudio()
                } else if hasRealVoice == false {
                    // Voice sample → back to upload step
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasRealVoice = true
                        manager.selectedVoiceTone = nil
                    }
                } else {
                    // Upload step → dismiss screen
                    dismiss()
                }
            })
                .padding(.top, 8)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if manager.audioFileURL != nil {
                        // Audio loaded → show player
                        audioLoadedState
                    } else if hasRealVoice == false {
                        // Voice sample picker
                        aiVoiceStep
                    } else {
                        // Default: upload options
                        uploadStep
                    }
                }
                .padding(.bottom, 100)
            }

            continueButton
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showAudioPicker) {
            AudioDocumentPicker { url in manager.setAudioFile(url) }
        }
        .onChange(of: videoPickerItem) { _, newItem in
            guard let item = newItem else { return }
            loadVideoAndExtract(item)
            videoPickerItem = nil
        }
        .navigationDestination(isPresented: $navigateToScript) {
            WeddingEditScriptView()
        }
        .onDisappear { stopAudio(); stopVoicePreview() }
        .onChange(of: manager.audioFileURL) { _, newURL in
            guard let url = newURL else { audioDurationCache = 0; return }
            Task {
                let asset = AVURLAsset(url: url)
                if let d = try? await asset.load(.duration) { audioDurationCache = CMTimeGetSeconds(d) }
            }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Upload
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private var uploadStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Upload \(speakerName)'s voice")
                .font(AppFont.dmSans(.bold, size: 24))
                .foregroundColor(.white)

            // Upload audio
            Button { showAudioPicker = true } label: {
                optionRow(icon: "mic.fill", title: "Upload audio", subtitle: "WAV or MP3 from your device")
            }
            .buttonStyle(.plain)

            // Extract from video
            PhotosPicker(selection: $videoPickerItem, matching: .videos, photoLibrary: .shared()) {
                optionRow(icon: "film", title: "Use a voice from video", subtitle: "We'll extract the audio track")
            }
            .buttonStyle(.plain)

            if let error = manager.audioError {
                errorBanner(error)
            }
            if manager.isExtractingAudio {
                extractingIndicator
            }

            // Link to voice sample
            HStack(spacing: 4) {
                Text("Don't have a recording?")
                    .font(AppFont.dmSans(.regular, size: 13))
                    .foregroundColor(AppColor.labelTertiary)
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasRealVoice = false
                        if manager.selectedVoiceTone == nil {
                            manager.selectedVoiceTone = manager.availableVoiceTones.first
                        }
                    }
                } label: {
                    Text("Choose a voice sample")
                        .font(AppFont.dmSans(.medium, size: 13))
                        .foregroundColor(AppColor.tabActive)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, 16)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Step NO: AI Voice
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private var aiVoiceStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How do you remember \(speakerName)'s voice?")
                .font(AppFont.dmSans(.bold, size: 24))
                .foregroundColor(.white)

            Text("Each voice carries a different warmth and emotion.")
                .font(AppFont.dmSans(.regular, size: 14))
                .foregroundColor(AppColor.labelSecondary)

            // Voice list
            VStack(spacing: 10) {
                ForEach(manager.availableVoiceTones) { tone in
                    voiceToneRow(tone)
                }
            }

        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, 16)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Audio Loaded State
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private var audioLoadedState: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(speakerName)'s voice is ready")
                .font(AppFont.dmSans(.bold, size: 24))
                .foregroundColor(.white)
                .padding(.top, 16)

            audioFileCard
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Shared Components
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func optionRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#2A2A2C")).frame(width: 48, height: 48)
                Image(systemName: icon).font(.system(size: 20, weight: .medium)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AppFont.dmSans(.semibold, size: 15)).foregroundColor(.white)
                Text(subtitle).font(AppFont.dmSans(.regular, size: 13)).foregroundColor(AppColor.labelSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.labelTertiary)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#1C1C1E")))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }

    private func voiceToneRow(_ tone: VoiceTone) -> some View {
        let isSelected = manager.selectedVoiceTone == tone
        let isPreviewing = previewingToneId == tone.id

        return Button {
            stopVoicePreview()
            withAnimation(.easeInOut(duration: 0.2)) {
                manager.selectedVoiceTone = tone
                if manager.audioFileURL != nil { stopAudio(); manager.removeAudio() }
            }
        } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tone.name)
                        .font(AppFont.dmSans(.semibold, size: 16))
                        .foregroundColor(.white)
                    Text(tone.description)
                        .font(AppFont.dmSans(.regular, size: 12))
                        .foregroundColor(AppColor.labelSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 12)
                // Play preview
                Button {
                    toggleVoicePreview(tone)
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 38, height: 38)
                        Image(systemName: isPreviewing ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .offset(x: isPreviewing ? 0 : 1)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color(hex: "#2A2A2C") : Color(hex: "#1C1C1E"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hex: "#F2333F").opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Audio File Card

    private var audioFileCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(audioFileName).font(AppFont.dmSans(.semibold, size: 15)).foregroundColor(.white).lineLimit(1)
                    Text("\(audioFileExtension) \u{00B7} \(formatTime(audioDuration)) \u{00B7} ready")
                        .font(AppFont.dmSans(.regular, size: 12)).foregroundColor(AppColor.labelSecondary)
                }
                Spacer()
                Button { stopAudio(); manager.removeAudio(); hasRealVoice = true } label: {
                    Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundColor(AppColor.labelTertiary)
                }.buttonStyle(.plain)
            }
            .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 12)

            HStack(spacing: 12) {
                Button { toggleAudioPlayback() } label: {
                    ZStack {
                        Circle().fill(Color.white).frame(width: 38, height: 38)
                        Image(systemName: isPlayingAudio ? "pause.fill" : "play.fill")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(.black)
                            .offset(x: isPlayingAudio ? 0 : 1)
                    }
                }.buttonStyle(.plain)
                HStack(spacing: 1.5) {
                    ForEach(0..<40, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.white.opacity(waveformBarOpacity(for: i)))
                            .frame(width: 2.5, height: waveformHeight(for: i))
                    }
                }.frame(height: 28)
            }
            .padding(.horizontal, 16)

            HStack {
                Text("\(formatTime(playbackTime)) / \(formatTime(audioDuration))")
                    .font(AppFont.dmSans(.regular, size: 12)).foregroundColor(AppColor.labelSecondary).monospacedDigit()
                Spacer()
                Button { stopAudio(); manager.removeAudio(); hasRealVoice = true } label: {
                    Text("Replace").font(AppFont.dmSans(.medium, size: 13)).foregroundColor(AppColor.tabActive)
                }.buttonStyle(.plain)
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 16)
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#1C1C1E")))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }

    // MARK: - Status Indicators

    private var extractingIndicator: some View {
        HStack(spacing: 12) {
            ProgressView().tint(.white)
            Text("Extracting audio...").font(AppFont.dmSans(.medium, size: 14)).foregroundColor(AppColor.labelSecondary)
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1C1C1E")))
    }

    private func errorBanner(_ msg: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 14, weight: .medium))
            Text(msg).font(AppFont.dmSans(.medium, size: 13))
        }
        .foregroundColor(Color(hex: "#F26B8C")).padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.06)))
    }

    // MARK: - Helpers

    private func waveformHeight(for i: Int) -> CGFloat {
        [4,6,3,10,8,14,6,20,12,24,18,10,28,16,8,22,14,6,18,26,20,12,8,16,24,10,18,6,14,22,8,28,16,10,20,12,6,18,14,8][i % 40]
    }
    private func waveformBarOpacity(for i: Int) -> Double {
        Double(i) / 40.0 <= (audioDuration > 0 ? playbackTime / audioDuration : 0) ? 0.9 : 0.35
    }

    // MARK: - Voice Preview (TTS)

    private func toggleVoicePreview(_ tone: VoiceTone) {
        previewingToneId == tone.id ? stopVoicePreview() : { stopVoicePreview(); playVoicePreview(tone) }()
    }
    private func playVoicePreview(_ tone: VoiceTone) {
        let u = AVSpeechUtterance(string: "My dearest, today my heart is so full. I am with you in every heartbeat.")
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        switch tone.id {
        case "father_warm","mother_warm": u.pitchMultiplier=1.0; u.rate=0.45
        case "father_deep": u.pitchMultiplier=0.8; u.rate=0.42
        case "father_soft","mother_gentle": u.pitchMultiplier=1.1; u.rate=0.40; u.volume=0.7
        case "mother_bright": u.pitchMultiplier=1.3; u.rate=0.48
        default: u.pitchMultiplier=1.0; u.rate=0.45
        }
        previewingToneId = tone.id; speechSynthesizer.stopSpeaking(at: .immediate); speechSynthesizer.speak(u)
        DispatchQueue.main.asyncAfter(deadline: .now()+8) { [self] in
            if previewingToneId == tone.id && !speechSynthesizer.isSpeaking { previewingToneId = nil }
        }
    }
    private func stopVoicePreview() { speechSynthesizer.stopSpeaking(at: .immediate); previewingToneId = nil }

    // MARK: - Audio Playback

    private func toggleAudioPlayback() { isPlayingAudio ? stopAudio() : playAudio() }
    private func playAudio() {
        guard let url = manager.audioFileURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url); audioPlayer?.play(); isPlayingAudio = true
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                Task { @MainActor in
                    if let p = audioPlayer { playbackTime = p.currentTime; if !p.isPlaying { stopAudio() } }
                }
            }
        } catch { isPlayingAudio = false }
    }
    private func stopAudio() {
        audioPlayer?.stop(); audioPlayer = nil; isPlayingAudio = false
        playbackTimer?.invalidate(); playbackTimer = nil; playbackTime = 0
    }
    private func formatTime(_ t: TimeInterval) -> String { String(format: "%02d:%02d", Int(t)/60, Int(t)%60) }

    // MARK: - Video Loading

    private func loadVideoAndExtract(_ item: PhotosPickerItem) {
        manager.isExtractingAudio = true; manager.audioError = nil
        item.loadTransferable(type: VideoTransferable.self) { result in
            Task { @MainActor in
                switch result {
                case .success(let v): if let v { manager.extractAudioFromVideo(v.url) } else { manager.isExtractingAudio = false; manager.audioError = "Failed to load video." }
                case .failure: manager.isExtractingAudio = false; manager.audioError = "Failed to load video."
                }
            }
        }
    }

    // MARK: - Continue

    private var continueButton: some View {
        let ok = manager.hasAudioSource
        return Button {
            stopAudio(); stopVoicePreview(); navigateToScript = true
        } label: {
            Text("Continue")
                .font(AppFont.dmSans(.bold, size: 17))
                .foregroundColor(ok ? .white : Color(hex: "#6B6B6E"))
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(Capsule().fill(ok ? Color(hex: "#8E0612") : Color(hex: "#2A2A2C")))
        }
        .disabled(!ok).buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.screenPadding).padding(.top, 10).padding(.bottom, 14)
    }
}

// MARK: - Waveform Animation

private struct WaveformAnimation: View {
    @State private var phase: CGFloat = 0

    private let barCount = 24
    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 3

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            HStack(spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(for: i))
                        .frame(width: barWidth, height: barHeight(for: i, date: timeline.date))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func barHeight(for index: Int, date: Date) -> CGFloat {
        let time = date.timeIntervalSinceReferenceDate
        let offset = Double(index) * 0.28
        let wave1 = sin(time * 2.2 + offset) * 0.4
        let wave2 = sin(time * 3.5 + offset * 1.3) * 0.25
        let wave3 = sin(time * 1.1 + offset * 0.7) * 0.2
        let normalized = (wave1 + wave2 + wave3 + 1.0) / 2.0  // 0...1
        return 6 + normalized * 36
    }

    private func barColor(for index: Int) -> Color {
        let center = Double(barCount) / 2.0
        let dist = abs(Double(index) - center) / center  // 0 at center, 1 at edges
        return Color.white.opacity(0.25 + (1.0 - dist) * 0.35)
    }
}

// MARK: - Document Picker

struct AudioDocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let p = UIDocumentPickerViewController(forOpeningContentTypes: [.wav, .mp3, .audio])
        p.delegate = context.coordinator; return p
    }
    func updateUIViewController(_ vc: UIDocumentPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }
        func documentPicker(_ c: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let u = urls.first else { return }; _ = u.startAccessingSecurityScopedResource(); onPick(u)
        }
    }
}

// MARK: - Video Transferable

struct VideoTransferable: Transferable {
    let url: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { v in SentTransferredFile(v.url) } importing: { r in
            let t = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(r.file.pathExtension)
            try FileManager.default.copyItem(at: r.file, to: t); return VideoTransferable(url: t)
        }
    }
}

#Preview {
    NavigationStack {
        WeddingUploadAudioView()
            .onAppear { WeddingTributeManager.shared.selectTemplate(WeddingTemplate.samples[0]) }
    }
    .preferredColorScheme(.dark)
}
