/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
An observable speech recognizer that wraps SFSpeechRecognizer and
AVAudioEngine to provide live, on-device dictation for voice search.
*/

import Foundation
import AVFoundation
import Speech

/// A high-level state for the recognizer that the UI can reflect.
enum VoiceRecognizerState: Equatable {
    case idle
    case requestingAuthorization
    case listening
    case stopping
    case unauthorized(reason: String)
    case failed(message: String)
}

/// An observable speech recognizer that captures microphone audio and
/// streams partial transcripts back on the main actor.
///
/// Usage:
/// ```swift
/// @State private var recognizer = SpeechRecognizer()
/// // ...
/// .task { await recognizer.startTranscribing() }
/// .onDisappear { recognizer.stopTranscribing() }
/// ```
@MainActor
@Observable
final class SpeechRecognizer {
    /// The most recent transcribed text. Updates live while listening.
    private(set) var transcript: String = ""

    /// The recognizer's current high-level state.
    private(set) var state: VoiceRecognizerState = .idle

    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    init(locale: Locale = .current) {
        recognizer = SFSpeechRecognizer(locale: locale)
    }

    // MARK: - Public API

    /// Begins listening to the microphone and producing transcripts.
    func startTranscribing() async {
        guard state != .listening else { return }

        state = .requestingAuthorization
        transcript = ""

        // Request speech recognition authorization.
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard speechStatus == .authorized else {
            state = .unauthorized(reason: Self.description(for: speechStatus))
            return
        }

        // Request microphone permission.
        let micGranted = await AVAudioApplication.requestRecordPermission()
        guard micGranted else {
            state = .unauthorized(reason: "Microphone access is required for voice search. Enable it in Settings.")
            return
        }

        guard let recognizer, recognizer.isAvailable else {
            state = .failed(message: "Speech recognition isn't available on this device right now.")
            return
        }

        do {
            try beginRecognition(with: recognizer)
            state = .listening
        } catch {
            cleanUpRecognition()
            state = .failed(message: error.localizedDescription)
        }
    }

    /// Ends the current listening session, leaving `transcript` populated.
    func stopTranscribing() {
        guard state == .listening else { return }
        state = .stopping
        cleanUpRecognition()
        state = .idle
    }

    /// Resets the transcript and returns the recognizer to idle.
    func reset() {
        cleanUpRecognition()
        transcript = ""
        state = .idle
    }

    // MARK: - Private

    private func beginRecognition(with recognizer: SFSpeechRecognizer) throws {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        self.request = request

        #if os(iOS) || os(visionOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)

        // The audio tap runs on a real-time audio thread. `append(_:)` on
        // SFSpeechAudioBufferRecognitionRequest is documented as safe to call
        // from any thread.
        nonisolated(unsafe) let capturedRequest = request
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            capturedRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            // The completion runs off the main actor; hop back to update UI state.
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.cleanUpRecognition()
                        self.state = .idle
                    }
                } else if let error {
                    self.cleanUpRecognition()
                    self.state = .failed(message: error.localizedDescription)
                }
            }
        }
    }

    private func cleanUpRecognition() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        request = nil
        task?.cancel()
        task = nil
        #if os(iOS) || os(visionOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    private static func description(for status: SFSpeechRecognizerAuthorizationStatus) -> String {
        switch status {
        case .denied: return "Speech recognition was denied. Enable it in Settings to use voice search."
        case .restricted: return "Speech recognition is restricted on this device."
        case .notDetermined: return "Speech recognition hasn't been authorized yet."
        case .authorized: return ""
        @unknown default: return "Speech recognition isn't available right now."
        }
    }
}
