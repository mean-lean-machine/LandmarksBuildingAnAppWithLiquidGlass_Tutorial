/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows a single landmark in a grid.
*/

import SwiftUI

/// A view that shows a single landmark in a grid.
struct LandmarkGridItemView: View {
    let landmark: Landmark

    var body: some View {
        Image(landmark.thumbnailImageName)
            .resizable()
            .accessibilityIdentifier("LandmarkGridItemView_Image_\(landmark.id)")
            .aspectRatio(1, contentMode: .fill)
            .overlay {
                ReadabilityRoundedRectangle()
            }
            .clipped()
            .cornerRadius(Constants.cornerRadius)
            .accessibilityIdentifier("LandmarkGridItemView_\(landmark.id)")
            .overlay(alignment: .bottom) {
                Text(landmark.name)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.bottom)
                    .accessibilityIdentifier("LandmarkGridItemView_Name_\(landmark.id)")
            }
    }
}

#Preview {
    let modelData = ModelData()
    let previewLandmark = modelData.landmarksById[1001] ?? modelData.landmarks.first!
    LandmarkGridItemView(landmark: previewLandmark)
}
