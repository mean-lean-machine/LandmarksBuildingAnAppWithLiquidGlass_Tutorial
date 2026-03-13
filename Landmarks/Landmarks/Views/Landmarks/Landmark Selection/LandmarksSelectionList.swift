/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows a list of landmarks, organized by continent, for selection.
*/

import SwiftUI

/// A view that shows a list of landmarks, organized by continent, for selection.
struct LandmarksSelectionList: View {
    @Environment(ModelData.self) var modelData
    @Binding var landmarks: [Landmark]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(ModelData.orderedContinents, id: \.self) { continent in
                    let sectionHeader = Text(continent.name)
                        .accessibilityIdentifier("LandmarksSelectionList_SectionHeader_\(continent.name)")
                    Section(header: sectionHeader) {
                        ForEach(modelData.landmarks(in: continent)) { landmark in
                            LandmarksSelectionListItem(landmark: landmark, landmarks: $landmarks)
                                .onTapGesture {
                                    if landmarks.contains(landmark) {
                                        if let landmarkIndex = landmarks.firstIndex(of: landmark) {
                                            landmarks.remove(at: landmarkIndex)
                                        }
                                    } else {
                                        landmarks.append(landmark)
                                    }
                                }
                        }
                    }
                }
            }
            .accessibilityIdentifier("LandmarksSelectionList_List")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationTitle("Select landmarks")
            .accessibilityIdentifier("LandmarksSelectionList_NavigationTitle")
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
                .accessibilityIdentifier("LandmarksSelectionList_DoneButton")
            }
        }
    }
}

#Preview {
    let modelData = ModelData()
    let previewCollection = modelData.userCollections.last!

    LandmarksSelectionList(landmarks: .constant(previewCollection.landmarks))
        .environment(modelData)
}
