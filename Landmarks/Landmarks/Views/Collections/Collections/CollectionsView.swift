/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows a person's favorite landmarks and custom landmark collections.
*/

import SwiftUI

/// A view that shows a person's favorite landmarks and custom landmark collections.
struct CollectionsView: View {
    @Environment(ModelData.self) var modelData

    var body: some View {
        @Bindable var modelData = modelData

        ScrollView(.vertical)
            .accessibilityIdentifier("CollectionsView_ScrollView") {
            LazyVStack {
                HStack {
                    CollectionTitleView(title: "Favorites", comment: "Section title above favorite collections.")
                        .accessibilityIdentifier("CollectionsView_FavoritesTitle")
                    Spacer()
                }
                .padding(.leading, Constants.leadingContentInset)
                .accessibilityIdentifier("CollectionsView_FavoritesTitle_HStack")
                
                LandmarkHorizontalListView(landmarkList: modelData.favoritesCollection.landmarks)
                    .containerRelativeFrame(.vertical) { height, axis in
                        let proposedHeight = height * Constants.landmarkListPercentOfHeight
                        if proposedHeight > Constants.landmarkListMinimumHeight {
                            return proposedHeight
                        }
                        return Constants.landmarkListMinimumHeight
                    }
                    .accessibilityIdentifier("CollectionsView_LandmarkHorizontalListView")

                HStack {
                    CollectionTitleView(title: "My Collections", comment: "Section title above the person's collections.")
                        .accessibilityIdentifier("CollectionsView_MyCollectionsTitle")
                    Spacer()
                }
                .padding(.leading, Constants.leadingContentInset)
                .accessibilityIdentifier("CollectionsView_MyCollectionsTitle_HStack")
                
                CollectionsGrid()
                    .padding(.leading, Constants.leadingContentInset)
                    .accessibilityIdentifier("CollectionsView_CollectionsGrid")
            }
        }
        .ignoresSafeArea(.keyboard, edges: [.bottom])
        .navigationTitle("Collections")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    let newCollection = modelData.addUserCollection()
                    modelData.path.append(newCollection)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("CollectionsView_AddCollectionButton")
            }
        }
        .navigationDestination(for: Landmark.self) { landmark in
            LandmarkDetailView(landmark: landmark)
        }
        .navigationDestination(for: LandmarkCollection.self) { collection in
            CollectionDetailView(collection: collection)
        }
    }
}

private struct CollectionTitleView: View {
    let title: LocalizedStringKey
    let comment: StaticString
    
    var body: some View {
        Text(title, comment: comment)
            .font(.title2)
            .bold()
            .padding(.top, Constants.titleTopPadding)
    }
}

#Preview {
    CollectionsView()
        .environment(ModelData())
}

