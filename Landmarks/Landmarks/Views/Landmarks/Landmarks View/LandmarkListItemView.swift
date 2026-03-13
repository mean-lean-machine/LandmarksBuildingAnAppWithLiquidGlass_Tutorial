/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows a single landmark in a list.
*/

import SwiftUI

/// A view that shows a single landmark in a list.
struct LandmarkListItemView: View {
    let landmark: Landmark

    var body: some View {
        Image(landmark.thumbnailImageName)
            .resizable()
            .accessibilityIdentifier("LandmarkListItemView_Image_\(landmark.id)")
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .overlay {
                ReadabilityRoundedRectangle()
            }
            .clipped()
            .cornerRadius(Constants.cornerRadius)
            .overlay(alignment: .bottom) {
                Text(landmark.name)
                    .font(.title3).fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.bottom)
                    .accessibilityIdentifier("LandmarkListItemView_Name_\(landmark.id)")
            }
            .contextMenu {
                ShareLink(item: landmark, preview: landmark.sharePreview)
                LandmarkFavoriteButton(landmark: landmark)
                LandmarkCollectionsMenu(landmark: landmark)
            }
            .accessibilityIdentifier("LandmarkListItemView_\(landmark.id)")
    }
}

#Preview {
    let modelData = ModelData()
    let previewLandmark = modelData.landmarksById[1001] ?? modelData.landmarks.first!
    LandmarkListItemView(landmark: previewLandmark)
        .frame(width: 252.0, height: 180.0)
}
