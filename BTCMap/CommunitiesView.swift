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
    
    var communitiesPlusDistance: [CommunityPlusDistance] {
        guard let currentLoc = locationManager.location else { return areasRepo.communities.map { CommunityPlusDistance(area: $0, distance: nil) } }
        return areasRepo.communities.map { (area) in
            guard let areaCoord = area.coord else { return CommunityPlusDistance(area: area, distance: nil) }
            return CommunityPlusDistance(area: area,
                                         distance: MapCalculations.haversineDistance(coord1: currentLoc.coordinate,
                                                                                     coord2: areaCoord))
        }
    }
    
    var communitiesSortedByDistance: [CommunityPlusDistance] {
        return communitiesPlusDistance.sorted { (community1, community2) -> Bool in
            if community1.distance == nil { return false }
            if community2.distance == nil { return true }
            return community1.distance! < community2.distance!
        }
    }
    
    // TODO: This is constantly getting refreshed
    var body: some View {
        VStack {
            List(communitiesSortedByDistance, id: \.area.id) { item in
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
