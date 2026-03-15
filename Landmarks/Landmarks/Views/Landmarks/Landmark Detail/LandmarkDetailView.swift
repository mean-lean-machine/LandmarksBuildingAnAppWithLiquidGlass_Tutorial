/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows a single landmark, with an image and description.
*/

import SwiftUI
import MapKit

/// A view that shows a single landmark, with an image and description.
struct LandmarkDetailView: View {
    @Environment(ModelData.self) private var modelData
    let landmark: Landmark

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: Constants.landmarkImagePadding) {
                Image(landmark.backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .backgroundExtensionEffect()
                    .flexibleHeaderContent()
                    .accessibilityIdentifier("LandmarkBckgndImage-\(landmark.id)")

                VStack(alignment: .leading) {
                    Text(landmark.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("LandmarkName-\(landmark.id)")

                    Text(landmark.description)
                        .textSelection(.enabled)
                        .accessibilityIdentifier("LandmarkDescription-\(landmark.id)")
                }
                .padding(.leading, Constants.leadingContentInset)
                .padding(.trailing, Constants.leadingContentInset * 2)
            }
        }
        .flexibleHeaderScrollView()
        .toolbar {
            ToolbarSpacer(.flexible)

            ToolbarItem {
                ShareLink(item: landmark, preview: landmark.sharePreview)
                    .accessibilityIdentifier("ShareButton-\(landmark.id)")
            }

            ToolbarSpacer(.fixed)
            
            ToolbarItemGroup {
                LandmarkFavoriteButton(landmark: landmark)
                    .accessibilityIdentifier("ToolbarFavoriteButton-\(landmark.id)")

                LandmarkCollectionsMenu(landmark: landmark)
                    .accessibilityIdentifier("ToolbarCollectionsMenu-\(landmark.id)")
            }
            
            ToolbarSpacer(.fixed)
        
            ToolbarItem {
                Button("Info", systemImage: "info") {
                    modelData.selectedLandmark = landmark
                    modelData.isLandmarkInspectorPresented.toggle()
                }
                .accessibilityIdentifier("InfoButton")
            }
        }
        .toolbar(removing: .title)
        .ignoresSafeArea(edges: .top)
    }
}

private struct FavoriteButtonLabel: View {
    var isFavorite: Bool
    var body: some View {
        Label(isFavorite ? "Unfavorite" : "Favorite", systemImage: "heart")
            .symbolVariant(isFavorite ? .fill : .none)
    }
}

#Preview {
    @Previewable @State var modelData = ModelData()
    let previewLandmark = modelData.landmarksById[1016] ?? modelData.landmarks.first!

    NavigationSplitView {
        List {
            Section {
                ForEach(NavigationOptions.mainPages) { page in
                    NavigationLink(value: page) {
                        Label(page.name, systemImage: page.symbolName)
                    }
                }
            }
        }
    } detail: {
        LandmarkDetailView(landmark: previewLandmark)
    }
    .inspector(isPresented: $modelData.isLandmarkInspectorPresented) {
        if let landmark = modelData.selectedLandmark {
            LandmarkDetailInspectorView(landmark: landmark, inspectorIsPresented: $modelData.isLandmarkInspectorPresented)
        } else {
            EmptyView()
        }
    }
    .environment(modelData)
    .onGeometryChange(for: CGSize.self) { geometry in
        geometry.size
    } action: {
        modelData.windowSize = $0
    }
}
