//
//  CommunitiesView.swift
//  BTCMap
//
//  Created by salva on 12/25/22.
//

import SwiftUI

struct CommunitiesView: View {
    let locationManager = LocationManager()
    @EnvironmentObject var areasRepo: AreasRepository
    @State private var searchText = ""

    /// Returns communities with a distance value, which can then be sorted by proximity to current user location.
    private var communitiesWithDistance: [CommunityPlusDistance] {
        guard let currentLoc = locationManager.location else { return areasRepo.communities.map { CommunityPlusDistance(area: $0, distance: nil) } }
        return areasRepo.communities.map { (area) in
            guard let areaCoord = area.centerCoord else { return CommunityPlusDistance(area: area, distance: nil) }
            return CommunityPlusDistance(area: area,
                                         distance: MapCalculations.haversineDistance(coord1: currentLoc.coordinate,
                                                                                     coord2: areaCoord))
        }
    }
    
    /// Returns communities without a distance value. This is used when a user has not authorized user location.
    private var communitiesWithoutDistance: [CommunityPlusDistance] {
        return areasRepo.communities.map { CommunityPlusDistance(area: $0, distance: nil) }
    }

    private var communities: [CommunityPlusDistance] {
        let allCommunities: [CommunityPlusDistance] = {
            switch locationManager.status {
                case .authorizedAlways, .authorizedWhenInUse:
                return communitiesWithDistance
                case .denied, .restricted, .notDetermined:
                return communitiesWithoutDistance
            @unknown default:
                fatalError()
            }
        }()
        
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
            SearchBar(searchText: $searchText, backgroundColor: Color.BTCMap_BackgroundBlue.opacity(0.5))

            List(communities, id: \.area.id) { item in
                let communityDetailViewModel = CommunityDetailViewModel(communityPlusDistance: item)
                NavigationLink(destination: CommunityDetailView(communityDetailViewModel: communityDetailViewModel)) {
                    HStack {
                        AsyncImage(url: item.area.iconUrl)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding([.trailing], 10)
                        
                        VStack(alignment: .leading) {
                            Text(item.area.name ?? "")
                                .font(.headline)
                            
                            Text(communityDetailViewModel.distanceText ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .navigationBarHidden(false)
        .navigationBarTitle("Communities", displayMode: .inline)
    }
}

//struct CommunitiesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommunitiesView()
//    }
//}
