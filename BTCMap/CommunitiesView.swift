//
//  CommunitiesView.swift
//  BTCMap
//
//  Created by salva on 12/25/22.
//

import SwiftUI

struct CommunitiesView: View {
    let locationManager = LocationManager()
    @EnvironmentObject var appState: AppState
    var areasRepo: AreasRepository { appState.areasRepository }
    @State private var searchText = ""

    /// Returns communities with a distance value, which can then be sorted by proximity to current user location.
    private var communitiesWithDistance: [AreaWithDistance] {
        guard let currentLoc = locationManager.location else { return areasRepo.communities.map { AreaWithDistance(area: $0, distance: nil) } }
        return areasRepo.communities.map { (area) in
            guard let areaCoord = area.centerCoord else { return AreaWithDistance(area: area, distance: nil) }
            return AreaWithDistance(area: area,
                                         distance: MapCalculations.haversineDistance(coord1: currentLoc.coordinate,
                                                                                     coord2: areaCoord))
        }
    }
    
    /// Returns communities without a distance value. This is used when a user has not authorized user location.
    private var communitiesWithoutDistance: [AreaWithDistance] {
        return areasRepo.communities.map { AreaWithDistance(area: $0, distance: nil) }
    }

    private var communities: [AreaWithDistance] {
        let allCommunities: [AreaWithDistance] = {
            switch locationManager.status {
                case .authorizedAlways, .authorizedWhenInUse:
                return communitiesWithDistance
                case .denied, .restricted, .notDetermined:
                return communitiesWithoutDistance
            @unknown default:
                fatalError()
            }
        }()
        
        // filter out for search
        let filteredCommunities = allCommunities.filter { community in
            searchText.isEmpty || (community.area.name?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        
        return filteredCommunities.sorted { (community1, community2) -> Bool in
            if community1.distance == nil { return false }
            if community2.distance == nil { return true }
            return community1.distance! < community2.distance!
        }        
    }
    
    var body: some View {
        VStack {
            SearchBar(searchText: $searchText, backgroundColor: Color.BTCMap_DiscordLightBlack)
            List(communities, id: \.area.id) { item in
                let communityDetailViewModel = CommunityDetailViewModel(areaWithDistance: item)
                let areaName = communityDetailViewModel.areaWithDistance.area.name ?? ""
                NavigationLink(destination: CommunityDetailView(communityDetailViewModel: communityDetailViewModel).navigationBarTitle(areaName, displayMode: .large)) {
                    HStack {
                        AsyncImage(url: item.area.iconUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                     .aspectRatio(contentMode: .fill)
                                     .frame(width: 40, height: 40)
                                     .clipShape(Circle())
                                     .padding([.trailing], 10)
                            case .empty:
                                ProgressView()
                                     .frame(width: 40, height: 40)
                                
                            @unknown default:
                                Image(systemName: "person.2.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .padding([.trailing], 10)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(item.area.name ?? "")
                                .font(.headline)
                            
                            Text(communityDetailViewModel.distanceText ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listRowSeparator(.visible)
                .listRowSeparatorTint(Color.BTCMap_DiscordLightBlack)
                .listRowBackground(Color.BTCMap_DiscordDarkBlack)
            }
            /// Show a background color overlay when results are empty
            .overlay(Group {
                if communities.isEmpty {
                    ZStack() {
                        Color.BTCMap_DiscordDarkBlack.ignoresSafeArea()
                        
                        VStack {
                            Text("no_results".localized)
                            Spacer()
                        }
                    }
                }
            })
            .background(Color.BTCMap_DiscordDarkBlack)
            .listStyle(.plain)
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarHidden(false)
        .navigationBarTitle("communities".localized, displayMode: .inline)
        .background(Color.BTCMap_DiscordDarkBlack)
    }
}

//struct CommunitiesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommunitiesView()
//    }
//}
