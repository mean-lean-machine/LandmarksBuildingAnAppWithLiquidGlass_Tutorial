/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A microphone button that presents a voice search sheet. On completion,
the dictated text is written to the bound search string.
*/

import SwiftUI

/// A toolbar-friendly microphone button. Tapping it presents
/// `VoiceSearchSheet`; when the user confirms, the transcript is written
/// to `searchText`.
struct VoiceSearchButton: View {
    @Binding var searchText: String
    @State private var isPresented: Bool = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Voice Search", systemImage: "mic.fill")
        }
        .accessibilityLabel("Search by voice")
        .accessibilityIdentifier("VoiceSearchButton")
        .sheet(isPresented: $isPresented) {
            VoiceSearchSheet { text in
                searchText = text
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview("Voice Search Button") {
    @Previewable @State var text = ""

    NavigationStack {
        VStack {
            Text("Search text:")
                .foregroundStyle(.secondary)
            Text(text.isEmpty ? "(empty)" : "\u{201C}\(text)\u{201D}")
                .font(.title3)
        }
        .padding()
        .toolbar {
            VoiceSearchButton(searchText: $text)
        }
    }
}
