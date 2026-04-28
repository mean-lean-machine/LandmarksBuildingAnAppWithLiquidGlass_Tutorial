/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A modal sheet that records the microphone, shows a live transcript,
and returns the result via a completion handler when the user confirms.
*/

import SwiftUI

/// A sheet that drives a `SpeechRecognizer` and provides Cancel / Use This
/// controls. The transcript is reported through `onComplete` only when
/// the user explicitly accepts it.
struct VoiceSearchSheet: View {
    var onComplete: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var recognizer = SpeechRecognizer()
    @State private var pulse: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            header
            transcriptCard
            Spacer(minLength: 0)
            micVisual
            Spacer(minLength: 0)
            controls
        }
        .padding()
        .task {
            await recognizer.startTranscribing()
            pulse = true
        }
        .onDisappear {
            recognizer.stopTranscribing()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 4) {
            Text(titleText)
                .font(.title2.weight(.semibold))
            Text(subtitleText)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var titleText: String {
        switch recognizer.state {
        case .listening: return "Listening\u{2026}"
        case .requestingAuthorization: return "Setting up\u{2026}"
        case .stopping: return "Wrapping up\u{2026}"
        case .unauthorized: return "Permission needed"
        case .failed: return "Something went wrong"
        case .idle: return "Voice Search"
        }
    }

    private var subtitleText: String {
        switch recognizer.state {
        case .idle: return "Tap the mic to start."
        case .requestingAuthorization: return "Requesting microphone access\u{2026}"
        case .listening: return "Try a landmark name like \u{201C}Eiffel Tower.\u{201D}"
        case .stopping: return "Finishing up\u{2026}"
        case .unauthorized(let reason): return reason
        case .failed(let reason): return reason
        }
    }

    // MARK: - Transcript

    private var transcriptCard: some View {
        ScrollView {
            Text(recognizer.transcript.isEmpty ? "\u{2014}" : recognizer.transcript)
                .font(.title3)
                .foregroundStyle(recognizer.transcript.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
                .padding()
        }
        .frame(maxHeight: 140)
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }

    // MARK: - Mic visual

    private var micVisual: some View {
        ZStack {
            Circle()
                .fill(.tint.opacity(0.15))
                .frame(width: 160, height: 160)
                .scaleEffect(pulseActive ? 1.18 : 1.0)
                .opacity(pulseActive ? 0.5 : 1.0)
                .animation(
                    pulseActive
                        ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                        : .default,
                    value: pulseActive
                )

            Circle()
                .fill(.tint.opacity(0.3))
                .frame(width: 110, height: 110)

            Image(systemName: micSymbolName)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.white)
                .contentTransition(.symbolEffect(.replace))
        }
        .accessibilityHidden(true)
    }

    private var pulseActive: Bool {
        pulse && recognizer.state == .listening
    }

    private var micSymbolName: String {
        switch recognizer.state {
        case .listening: return "mic.fill"
        case .unauthorized, .failed: return "mic.slash.fill"
        default: return "mic"
        }
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 16) {
            Button(role: .cancel) {
                recognizer.stopTranscribing()
                dismiss()
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                recognizer.stopTranscribing()
                let final = recognizer.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                if !final.isEmpty {
                    onComplete(final)
                }
                dismiss()
            } label: {
                Text("Use This")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(recognizer.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}

#Preview("Voice Search Sheet") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            VoiceSearchSheet { result in
                print("Voice search returned: \(result)")
            }
            .presentationDetents([.medium, .large])
        }
}
