/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows a featured landmark, and other landmarks organized by continent.
*/

import SwiftUI

/// A view that shows a featured landmark, and other landmarks organized by continent.
struct LandmarksView: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        @Bindable var modelData = modelData

        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: Constants.standardPadding) {

                LandmarkFeaturedItemView(landmark: modelData.featuredLandmark!)
                    .flexibleHeaderContent()
                    .accessibilityIdentifier("LandmarksView_FeaturedItem")

                ForEach(ModelData.orderedContinents, id: \.self) { continent in
                    Group {
                        ContinentTitleView(title: continent.name)
                        if let landmarkList = modelData.landmarksByContinent[continent] {
                            LandmarkHorizontalListView(landmarkList: landmarkList)
                                .accessibilityIdentifier("LandmarksView_ContinentSection_\(continent.name)")
                                .containerRelativeFrame(.vertical) { height, axis in
                                    let proposedHeight = height * Constants.landmarkListPercentOfHeight
                                    if proposedHeight > Constants.landmarkListMinimumHeight {
                                        return proposedHeight
                                    }
                                    return Constants.landmarkListMinimumHeight
                                }
                        }
                    }
                }
            }
        }
        .flexibleHeaderScrollView()
        .ignoresSafeArea(.keyboard)
        .ignoresSafeArea(edges: .top)
        .accessibilityIdentifier("LandmarksView_ScrollView")
        .toolbar(removing: .title)
        .navigationDestination(for: Landmark.self) { landmark in
            LandmarkDetailView(landmark: landmark)
        }
    }
}

private struct ContinentTitleView: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .bold()
            .padding(.top, Constants.titleTopPadding)
            .padding(.bottom, Constants.titleBottomPadding)
            .padding(.leading, Constants.leadingContentInset)
            .accessibilityIdentifier("LandmarksView_ContinentTitle_\(title)")
    }
}

#Preview {
    @Previewable @State var modelData = ModelData()
    
    LandmarksView()
        .environment(modelData)
        .onGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: {
            modelData.windowSize = $0
        }
}
