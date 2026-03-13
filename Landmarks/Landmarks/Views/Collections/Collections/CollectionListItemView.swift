/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that represents a single landmark collection in a grid.
*/

import SwiftUI

/// A view that represents a single landmark collection in a grid.
struct CollectionListItemView: View {
    let collection: LandmarkCollection

    var body: some View {
        VStack {
            collection.imageForListItem()
                .cornerRadius(Constants.cornerRadius)
                .accessibilityIdentifier("CollectionListItemView_Image")
            Text(collection.name)
                .accessibilityIdentifier("CollectionListItemView_Name")
            Text("\(collection.landmarks.count) items")
                .font(.callout)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("CollectionListItemView_Count")
        }
        .accessibilityIdentifier("CollectionListItemView_VStack")
    }
}

#Preview {
    let modelData = ModelData()
    let previewCollection = modelData.userCollections.first!

    CollectionListItemView(collection: previewCollection)
}
