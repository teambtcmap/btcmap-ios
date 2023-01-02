//
//  CommunitiesView.swift
//  BTCMap
//
//  Created by salva on 12/25/22.
//

import SwiftUI

struct CommunitiesView: View {
    // TODO: Pass API as Environment
    @StateObject var communitesViewModel = CommunitiesViewModel(api: API())
    
    var body: some View {
        VStack {
            List {
                ForEach(communitesViewModel.communities, id: \.self) { item in
                    
                    // TODO: Tap on row leads to community page
                    HStack {
                        AsyncImage(url: item.iconUrl)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            
                            // TODO: Calculate distance to user for detail text
                            //Text("distance")
                            //    .font(.subheadline)
                            //    .foregroundColor(.gray)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .navigationBarHidden(false)
        .navigationTitle("communities".localized)
    }
}



//struct CommunitiesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommunitiesView()
//    }
//}
