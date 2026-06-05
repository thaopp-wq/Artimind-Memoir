import SwiftUI
import AVFoundation

// MARK: - Category

enum TributeCategory: String, CaseIterable, Identifiable {
    case memorial  = "Memorial"
    case birthday  = "Birthday"
    case wedding   = "Wedding"
    case thankYou  = "Thank You"
    case general   = "General"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .memorial: return "candle.fill"
        case .birthday: return "gift.fill"
        case .wedding:  return "heart.fill"
        case .thankYou: return "hands.clap.fill"
        case .general:  return "message.fill"
        }
    }

    var scriptSuggestion: String {
        switch self {
        case .memorial:
            return "I may not be there in person, but I\u{2019}m always with you. I\u{2019}m so proud of who you\u{2019}ve become."
        case .birthday:
            return "Happy birthday! I wish I could be there to celebrate with you. You bring so much joy to everyone around you."
        case .wedding:
            return "Today you begin a beautiful new chapter. Even though I can\u{2019}t be there, my love is with you always."
        case .thankYou:
            return "Thank you for everything you\u{2019}ve done for me. Your kindness has meant more than words can say."
        case .general:
            return ""
        }
    }
}

// MARK: - Session

class VoiceTributeSession: ObservableObject {
    static let shared = VoiceTributeSession()

    @Published var category: TributeCategory = .general
    @Published var photo: UIImage?
    @Published var audioURL: URL?
    @Published var selectedVoiceTone: VoiceTone?
    @Published var scriptText: String = ""
    @Published var isRecording = false

    @Published var isExtractingAudio = false

    // Processing state
    @Published var isProcessing = false
    @Published var progress: CGFloat = 0
    @Published var statusText = ""

    private var audioRecorder: AVAudioRecorder?
    private var meterTimer: Timer?
    @Published var audioLevel: CGFloat = 0
    @Published var recordingDuration: TimeInterval = 0

    var hasPhoto: Bool { photo != nil }
    var hasAudio: Bool { audioURL != nil || selectedVoiceTone != nil }

    static let defaultVoices: [VoiceTone] = [
        VoiceTone(id: "male_warm", name: "Warm Male", description: "Gentle and comforting"),
        VoiceTone(id: "male_deep", name: "Deep Male", description: "Strong and reassuring"),
        VoiceTone(id: "female_soft", name: "Soft Female", description: "Tender and caring"),
        VoiceTone(id: "female_bright", name: "Bright Female", description: "Light and uplifting"),
        VoiceTone(id: "elder_male", name: "Elder Male", description: "Wise and steady"),
        VoiceTone(id: "elder_female", name: "Elder Female", description: "Warm and nurturing"),
    ]
    var hasScript: Bool { !scriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var wordCount: Int {
        scriptText.split(separator: " ").count
    }

    func reset() {
        category = .general
        photo = nil
        audioURL = nil
        selectedVoiceTone = nil
        scriptText = ""
        isRecording = false
        isProcessing = false
        progress = 0
        statusText = ""
    }

    // MARK: - Audio recording

    @Published var micDenied = false

    func startRecording() {
        // Reset state first
        meterTimer?.invalidate()
        meterTimer = nil
        isRecording = false
        recordingDuration = 0
        audioLevel = 0

        #if targetEnvironment(simulator)
        // Skip permission on simulator — fake recording
        isRecording = true
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.recordingDuration += 0.1
                self.audioLevel = CGFloat.random(in: 0.1...0.8)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        meterTimer = timer
        #else
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            beginRecording()
        case .denied:
            micDenied = true
        case .undetermined:
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    if granted { self?.beginRecording() }
                    else { self?.micDenied = true }
                }
            }
        @unknown default:
            break
        }
        #endif
    }

    private func beginRecording() {
        print("[Recording] beginRecording called")
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Audio session error: \(error)")
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("voice_tribute_\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.isMeteringEnabled = true
            let started = recorder.record()
            guard started else {
                print("Recorder failed to start")
                return
            }
            audioRecorder = recorder
        } catch {
            print("Recorder init error: \(error)")
            return
        }

        isRecording = true
        recordingDuration = 0

        let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0)
            let normalized = max(0, min(1, (power + 50) / 50))
            DispatchQueue.main.async {
                self.audioLevel = CGFloat(normalized)
                self.recordingDuration = recorder.currentTime
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        meterTimer = timer
    }

    func stopRecording() {
        meterTimer?.invalidate()
        meterTimer = nil
        #if targetEnvironment(simulator)
        // Fake audio URL for simulator
        let fakeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("fake_recording_\(UUID().uuidString).m4a")
        FileManager.default.createFile(atPath: fakeURL.path, contents: nil)
        audioURL = fakeURL
        #else
        audioRecorder?.stop()
        audioURL = audioRecorder?.url
        audioRecorder = nil
        #endif
        isRecording = false
        audioLevel = 0
    }

    func removeAudio() {
        if let url = audioURL {
            try? FileManager.default.removeItem(at: url)
        }
        audioURL = nil
    }

    // MARK: - Extract audio from video

    func extractAudioFromVideo(_ videoURL: URL) {
        isExtractingAudio = true
        let asset = AVAsset(url: videoURL)
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tribute_extracted_\(UUID().uuidString).m4a")

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            isExtractingAudio = false
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a

        exportSession.exportAsynchronously { [weak self] in
            DispatchQueue.main.async {
                self?.isExtractingAudio = false
                if exportSession.status == .completed {
                    self?.audioURL = outputURL
                }
            }
        }
    }

    // MARK: - Fake processing

    func startProcessing() {
        isProcessing = true
        progress = 0

        let steps: [(CGFloat, String, Double)] = [
            (0.25, "Analyzing photo...", 0.0),
            (0.50, "Processing voice...", 1.0),
            (0.75, "Generating lip-sync...", 2.0),
            (1.00, "Finalizing video...", 3.0),
        ]

        for step in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + step.2) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    self.progress = step.0
                    self.statusText = step.1
                }
            }
        }
    }
}
