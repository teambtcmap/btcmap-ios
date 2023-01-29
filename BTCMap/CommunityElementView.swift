//
//  CommunityElementView.swift
//  BTCMap
//
//  Created by salva on 1/20/23.
//

import Foundation
import SwiftUI

struct CommunityElementView: View {
    @EnvironmentObject var appState: AppState
    var communityDetailViewModel: CommunityDetailViewModel
    var element: API.Element
    
    // TODO: Tap - Map on CommunityElement - Go to mapVC centered on annotation

    var body: some View {
        let elementViewModel = ElementViewModel(element: element)
        GeometryReader { geometry in
            VStack {
                List {
                    // MARK: - Map
                    ZStack(alignment: .top) {
                        BoundedMapView(element: element,
                                       region: BoundedMapView.region(from: communityDetailViewModel.area.bounds ?? Bounds.zeroBounds))
                            .frame(height: geometry.size.height * 0.3)
                            .frame( maxWidth: .infinity)
                            .onTapGesture {
                                // hack to pop back to home. see note in AppState
                                appState.homeViewId = UUID()
                                appState.mapState.centerCoordinate = element.coord
                            }
                        
                        NavBarTitleSubtitle(title: element.osmJson.name, subtitle: "")
                    }
                    .listRowSeparator(.hidden)
                    
                    // MARK: - Name
                    Text(element.osmJson.name)
                        .font(.title2)
                        .padding(.horizontal)
                        .listRowSeparator(.hidden)

                    // MARK: - Verified
                    ElementVerifyView(elementViewModel: elementViewModel,
                                      notVerifiedTextType: .long)
                        .listRowSeparator(.hidden)

                    // MARK: - Details
                    ElementTagsView(elementViewModel: elementViewModel)
                        .listRowSeparator(.hidden)

                }
                .listStyle(.plain)
                .frame( maxWidth: .infinity)
                .edgesIgnoringSafeArea(.horizontal)
                
            }
        }
    }
}

struct CommunityElementView_Previews: PreviewProvider {
    static var previews: some View {
        let community = CommunityPlusDistance(area: API.Area.mock!, distance: nil)
        let viewModel = CommunityDetailViewModel(communityPlusDistance: community)
        let element = API.Element.mock!
        CommunityElementView(communityDetailViewModel: viewModel, element: element)
    }
}
