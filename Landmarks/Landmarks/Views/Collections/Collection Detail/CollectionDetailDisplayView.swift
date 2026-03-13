/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows a collection's title, description, and list of landmarks.
*/

import SwiftUI

/// A view that shows a collection's title, description, and list of landmarks.
struct CollectionDetailDisplayView: View {
    @Bindable var collection: LandmarkCollection
    
    var body: some View {
        VStack() {
            HStack {
                Text(collection.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding([.top])
                    .accessibilityIdentifier("collectionTitle")
                Spacer()
            }
            HStack {
                Text(collection.description)
                    .font(.title2)
                    .padding([.top, .bottom])
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("collectionDescription")
                Spacer()
            }
            LandmarksGrid(landmarks: $collection.landmarks, forEditing: false)
                .accessibilityIdentifier("landmarksGrid")
        }
        .padding([.leading, .trailing], Constants.leadingContentInset)
    }
}

#Preview {
    let modelData = ModelData()
    let previewCollection = modelData.userCollections.last!

    CollectionDetailDisplayView(collection: previewCollection)
}
