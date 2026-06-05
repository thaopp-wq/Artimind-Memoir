import Foundation
import SwiftUI
import UIKit
import AVFoundation

// MARK: - Voice Tone

struct VoiceTone: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String

    static func tones(for role: WeddingTemplate.SpeakerRole) -> [VoiceTone] {
        switch role {
        case .father:
            return [
                VoiceTone(id: "father_calm_attentive",  name: "Calm Attentive",   description: "Soft, steady, and fully present"),
                VoiceTone(id: "father_calm_sincere",    name: "Calm Sincere",     description: "Quiet, honest, and from the heart"),
                VoiceTone(id: "father_grateful_soft",   name: "Grateful Soft",    description: "Gentle, with a sense of appreciation"),
                VoiceTone(id: "father_inviting_warm",   name: "Inviting Warm",    description: "Open and welcoming, like a warm embrace"),
                VoiceTone(id: "father_joyful_bright",   name: "Joyful Bright",    description: "Light and uplifting, full of happiness"),
                VoiceTone(id: "father_loving_gentle",   name: "Loving Gentle",    description: "Tender and caring, like a lullaby"),
                VoiceTone(id: "father_proud_excited",   name: "Proud Excited",    description: "Beaming with pride and enthusiasm"),
            ]
        case .mother:
            return [
                VoiceTone(id: "mother_calm_attentive",  name: "Calm Attentive",   description: "Soft, steady, and fully present"),
                VoiceTone(id: "mother_calm_sincere",    name: "Calm Sincere",     description: "Quiet, honest, and from the heart"),
                VoiceTone(id: "mother_grateful_soft",   name: "Grateful Soft",    description: "Gentle, with a sense of appreciation"),
                VoiceTone(id: "mother_inviting_warm",   name: "Inviting Warm",    description: "Open and welcoming, like a warm embrace"),
                VoiceTone(id: "mother_joyful_bright",   name: "Joyful Bright",    description: "Light and uplifting, full of happiness"),
                VoiceTone(id: "mother_loving_gentle",   name: "Loving Gentle",    description: "Tender and caring, like a lullaby"),
                VoiceTone(id: "mother_proud_excited",   name: "Proud Excited",    description: "Beaming with pride and enthusiasm"),
            ]
        }
    }
}

// MARK: - Processing Step

enum WeddingProcessingStep: Int, CaseIterable {
    case analyzePhotos = 0
    case analyzeAudio = 1
    case generateVoice = 2
    case generateVideo = 3

    var title: String {
        switch self {
        case .analyzePhotos: return "Analyze your photos"
        case .analyzeAudio: return "Analyze audio reference"
        case .generateVoice: return "Generate voice"
        case .generateVideo: return "Generate tribute video"
        }
    }

    var completionDescription: String {
        switch self {
        case .analyzePhotos: return "Photos validated and prepared for video generation."
        case .analyzeAudio: return "Voice reference processed successfully."
        case .generateVoice: return "Cloning voice from audio reference..."
        case .generateVideo: return "Creating tribute video with lip-sync..."
        }
    }
}

enum WeddingStepStatus {
    case pending
    case inProgress
    case completed
    case failed
}

// MARK: - Manager

@MainActor
final class WeddingTributeManager: ObservableObject {
    static let shared = WeddingTributeManager()

    // Template
    @Published var selectedTemplate: WeddingTemplate?

    // Photos
    @Published var photos: [UIImage?] = []
    @Published var photoErrors: [String?] = []

    // Audio
    @Published var audioFileURL: URL?
    @Published var audioError: String?            // format/loading errors
    @Published var isExtractingAudio = false
    @Published var selectedVoiceTone: VoiceTone?
    @Published var isPreviewingVoice = false

    // Script
    @Published var scriptText: String = ""
    @Published var brideName: String = ""
    @Published var groomName: String = ""

    // Processing
    @Published var isProcessing = false
    @Published var currentStep: WeddingProcessingStep = .analyzePhotos
    @Published var stepStatuses: [WeddingProcessingStep: WeddingStepStatus] = [:]
    @Published var overallProgress: CGFloat = 0
    @Published var processingFailed = false
    @Published var processingComplete = false

    // Output
    @Published var outputVideoURL: URL?

    private var processingTimer: Timer?

    private init() {}

    // MARK: - Setup

    /// Available voice tones for the current template's speaker role.
    var availableVoiceTones: [VoiceTone] {
        guard let role = selectedTemplate?.speakerRole else { return [] }
        return VoiceTone.tones(for: role)
    }

    /// True when user has a valid audio source:
    /// - Uploaded/extracted audio file, OR
    /// - Selected voice tone
    var hasAudioSource: Bool {
        audioFileURL != nil || selectedVoiceTone != nil
    }

    func selectTemplate(_ template: WeddingTemplate) {
        reset()
        selectedTemplate = template
        photos = Array(repeating: nil, count: template.peopleNumber)
        photoErrors = Array(repeating: nil, count: template.peopleNumber)
        photoWarnings = Array(repeating: nil, count: template.peopleNumber)
        scriptText = template.scriptTemplate
        // Default-select the first voice tone
        selectedVoiceTone = VoiceTone.tones(for: template.speakerRole).first
        for step in WeddingProcessingStep.allCases {
            stepStatuses[step] = .pending
        }
    }

    func reset() {
        selectedTemplate = nil
        photos = []
        photoErrors = []
        photoWarnings = []
        audioFileURL = nil
        audioError = nil
        isExtractingAudio = false
        selectedVoiceTone = nil
        isPreviewingVoice = false
        scriptText = ""
        brideName = ""
        groomName = ""
        isProcessing = false
        currentStep = .analyzePhotos
        stepStatuses = [:]
        overallProgress = 0
        processingFailed = false
        processingComplete = false
        outputVideoURL = nil
        processingTimer?.invalidate()
        processingTimer = nil
    }

    // MARK: - Photo Validation

    /// Number of photos uploaded.
    var uploadedPhotoCount: Int {
        photos.compactMap { $0 }.count
    }

    /// Continue enabled when at least 1 photo uploaded (all photos accepted).
    var canContinuePhotos: Bool {
        uploadedPhotoCount >= 1
    }

    /// Warning text per slot (non-blocking, just guidance).
    @Published var photoWarnings: [String?] = []

    func setPhoto(_ image: UIImage, at index: Int) {
        guard index < photos.count else { return }
        photos[index] = image
        photoErrors[index] = nil
        if index < photoWarnings.count { photoWarnings[index] = nil }

        // Run quality check (non-blocking — just sets warning)
        guard let imageData = image.jpegData(compressionQuality: 0.9)
                ?? image.pngData() else { return }

        let data = imageData
        let mgr = self
        Task.detached {
            let faceCount = Self.countFaces(in: data)
            let imageSize = image.size
            await MainActor.run {
                guard index < mgr.photoWarnings.count else { return }
                if faceCount == 0 {
                    mgr.photoWarnings[index] = "No face detected. A clear face photo works best."
                } else if imageSize.width < 200 || imageSize.height < 200 {
                    mgr.photoWarnings[index] = "Low resolution. A higher quality photo works best."
                } else {
                    mgr.photoWarnings[index] = nil
                }
            }
        }
    }

    func removePhoto(at index: Int) {
        guard index < photos.count else { return }
        photos[index] = nil
        photoErrors[index] = nil
        if index < photoWarnings.count { photoWarnings[index] = nil }
    }

    /// Synchronous, thread-safe face detection. Runs entirely off the MainActor.
    nonisolated private static func countFaces(in imageData: Data) -> Int {
        // Primary: Vision with raw data (handles EXIF orientation automatically)
        do {
            let request = VNDetectFaceRectanglesRequest()
            let handler = VNImageRequestHandler(data: imageData, options: [:])
            try handler.perform([request])
            if let results = request.results {
                return results.count
            }
        } catch {
            // Fall through to CIDetector
        }

        // Fallback: CIDetector (proven reliable across all iOS versions)
        guard let ciImage = CIImage(data: imageData) else { return 0 }
        let detector = CIDetector(
            ofType: CIDetectorTypeFace,
            context: nil,
            options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        )
        return detector?.features(in: ciImage).count ?? 0
    }

    // MARK: - Audio

    func setAudioFile(_ url: URL) {
        audioError = nil

        let ext = url.pathExtension.lowercased()
        guard ext == "wav" || ext == "mp3" || ext == "m4a" else {
            audioError = "Unsupported format. Please upload a WAV or MP3 file."
            url.stopAccessingSecurityScopedResource()
            return
        }

        let localURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)
        do {
            try FileManager.default.copyItem(at: url, to: localURL)
            audioFileURL = localURL
            selectedVoiceTone = nil
        } catch {
            audioError = "Failed to load audio file. Please try again."
        }
        url.stopAccessingSecurityScopedResource()
    }

    func extractAudioFromVideo(_ videoURL: URL) {
        // Guard against double-trigger — view already sets isExtractingAudio
        if !isExtractingAudio { isExtractingAudio = true }
        audioError = nil

        let url = videoURL
        let mgr = self
        Task.detached {
            defer {
                try? FileManager.default.removeItem(at: url)
            }

            do {
                let asset = AVURLAsset(url: url)
                let audioTracks = try await asset.loadTracks(withMediaType: .audio)

                guard !audioTracks.isEmpty else {
                    await MainActor.run {
                        mgr.isExtractingAudio = false
                        mgr.audioError = "No audio found in video. Please upload a different file."
                    }
                    return
                }

                let outputURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("m4a")

                guard let session = AVAssetExportSession(
                    asset: asset,
                    presetName: AVAssetExportPresetAppleM4A
                ) else {
                    await MainActor.run {
                        mgr.isExtractingAudio = false
                        mgr.audioError = "Failed to extract audio. Please try again."
                    }
                    return
                }

                session.outputURL = outputURL
                session.outputFileType = .m4a
 
                let success: Bool
                do {
                    try await session.export(to: outputURL, as: .m4a)
                    success = true
                } catch {
                    success = false
                }

                await MainActor.run {
                    mgr.isExtractingAudio = false
                    if success {
                        mgr.audioFileURL = outputURL
                        mgr.selectedVoiceTone = nil
                    } else {
                        mgr.audioError = "Failed to extract audio. Please try again."
                    }
                }
            } catch {
                await MainActor.run {
                    mgr.isExtractingAudio = false
                    mgr.audioError = "Failed to extract audio. Please try again."
                }
            }
        }
    }

    func removeAudio() {
        audioFileURL = nil
        audioError = nil
    }

    // MARK: - Script

    /// Returns the script with name placeholders replaced.
    var assembledScript: String {
        var text = scriptText
        if !brideName.isEmpty {
            text = text.replacingOccurrences(of: "{bride_name}", with: brideName)
        }
        if !groomName.isEmpty {
            text = text.replacingOccurrences(of: "{groom_name}", with: groomName)
        }
        return text
    }

    // MARK: - Processing (Simulated)

    func startProcessing() {
        guard !isProcessing else { return }
        isProcessing = true
        processingFailed = false
        processingComplete = false
        overallProgress = 0
        currentStep = .analyzePhotos

        for step in WeddingProcessingStep.allCases {
            stepStatuses[step] = .pending
        }
        stepStatuses[.analyzePhotos] = .inProgress

        simulateProcessing()
    }

    func cancelProcessing() {
        processingTimer?.invalidate()
        processingTimer = nil
        isProcessing = false
        overallProgress = 0
        processingFailed = false
        processingComplete = false
    }

    private func simulateProcessing() {
        let totalDuration: TimeInterval = 30
        let tickInterval: TimeInterval = 0.3
        let step = CGFloat(tickInterval / totalDuration)

        // Step boundaries: each step covers 25%
        let stepBoundaries: [(WeddingProcessingStep, CGFloat)] = [
            (.analyzePhotos, 0.25),
            (.analyzeAudio, 0.50),
            (.generateVoice, 0.75),
            (.generateVideo, 1.0),
        ]

        processingTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else { timer.invalidate(); return }

                self.overallProgress = min(1.0, self.overallProgress + step)

                // Update step statuses based on progress
                for (stepCase, boundary) in stepBoundaries {
                    let prevBoundary = stepCase.rawValue > 0 ? stepBoundaries[stepCase.rawValue - 1].1 : 0
                    if self.overallProgress >= boundary {
                        self.stepStatuses[stepCase] = .completed
                    } else if self.overallProgress >= prevBoundary {
                        self.stepStatuses[stepCase] = .inProgress
                        self.currentStep = stepCase
                    }
                }

                if self.overallProgress >= 1.0 {
                    timer.invalidate()
                    self.processingTimer = nil
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    self.isProcessing = false
                    self.processingComplete = true
                }
            }
        }
    }
}

// MARK: - Vision Import

import Vision
import ImageIO

// MARK: - UIImage Orientation → CGImagePropertyOrientation

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up:            self = .up
        case .upMirrored:    self = .upMirrored
        case .down:          self = .down
        case .downMirrored:  self = .downMirrored
        case .left:          self = .left
        case .leftMirrored:  self = .leftMirrored
        case .right:         self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:    self = .up
        }
    }
}
