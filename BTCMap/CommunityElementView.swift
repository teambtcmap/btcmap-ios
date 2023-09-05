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
        List {
            // MARK: - Map
            let bounds = communityDetailViewModel.areaWithDistance.area.bounds
            BoundedMapView(element: element,
                           region: BoundedMapView.region(from: bounds ?? Bounds.zeroBounds, coordinates: element.coord, padding: 0.1))
            .frame(height: UIScreen.main.bounds.height * 0.23)
            .frame( maxWidth: .infinity)
            .onTapGesture {
                // hack to pop back to home. see note in AppState
                appState.homeViewId = UUID()
                appState.mapState.centerCoordinate = element.coord
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            // MARK: - Verified
            HStack {
                ElementVerifyView(elementViewModel: elementViewModel,
                                  notVerifiedTextType: .long)
            }
            .listRowSeparator(.hidden)
            .padding(.horizontal)
            .listRowBackground(Color.clear)
            
            // MARK: - Details
            HStack {
                ElementTagsView(elementViewModel: elementViewModel)
            }
            .listRowSeparator(.hidden)
            .padding(.horizontal)
            .listRowBackground(Color.clear)
        }
        .background(Color.BTCMap_DiscordDarkBlack)
        .listStyle(.plain)
        .frame( maxWidth: .infinity)
        .edgesIgnoringSafeArea(.horizontal)
        .navigationBarTitle(element.osmJson.name, displayMode: SwiftUI.NavigationBarItem.TitleDisplayMode.large)
    }
}

struct CommunityElementView_Previews: PreviewProvider {
    static var previews: some View {
        let community = AreaWithDistance(area: API.Area.mock!, distance: nil)
        let viewModel = CommunityDetailViewModel(areaWithDistance: community)
        let element = API.Element.mock!
        CommunityElementView(communityDetailViewModel: viewModel, element: element)
    }
}
