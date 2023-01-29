//
//  CommunityDetailView.swift
//  BTCMap
//
//  Created by salva on 1/20/23.
//

import MapKit
import SwiftUI

struct CommunityDetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var elementsRepo: ElementsRepository
    var communityDetailViewModel: CommunityDetailViewModel
    
    var elements: Array<API.Element> {
        guard let bounds = communityDetailViewModel.area.bounds else { return [] }
        return elementsRepo.elements(from: bounds)
            .filter { !$0.osmJson.name.isEmpty }
            .sorted { $0.osmJson.name < $1.osmJson.name }
    }
    
    // TODO: Not verified text pink like in ElementView    

    var body: some View {
        GeometryReader { geometry in
            VStack {
                List {
                    // MARK: - Map
                    ZStack(alignment: .top) {
                        let bounds = communityDetailViewModel.area.bounds
                        BoundedMapView(region: BoundedMapView.region(from: bounds ?? Bounds.zeroBounds))
                            .frame(height: geometry.size.height * 0.3)
                            .frame( maxWidth: .infinity)
                            .onTapGesture {
                                // hack to pop back to home. see note in AppState
                                appState.homeViewId = UUID()
                                appState.mapState.bounds = bounds
                            }
                        let placesText = elements.count == 1 ? "place_singular".localized : "places_plural".localized
                        NavBarTitleSubtitle(title: communityDetailViewModel.area.name ?? "" , subtitle: "\(elements.count) \(placesText)")
                    }
                    .listRowSeparator(.hidden)
                    
                    
                    // MARK: - Contact Buttons
                    HStack {
                        ForEach(communityDetailViewModel.contacts, id: \.self) { contact in
                            ImageCircle(image: contact.displayIcon,
                                        diameter: 45,
                                        imageColor: .white,
                                        backgroundColor: Color.BTCMap_DarkBeige)
                            .padding(4)
                            .onTapGesture {                           
                                guard let url = contact.url(from: communityDetailViewModel.area) else { return }
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .padding([.top, .bottom], 6)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    
                    // MARK: - Elements
                    ForEach(elements) { item in
                        NavigationLink(destination: CommunityElementView(communityDetailViewModel: communityDetailViewModel, element: item)) {
                            
                            let elementViewModel = ElementViewModel(element: item)
                            HStack {
                                ImageCircle(image: ElementSystemImages.swiftUISystemImage(for: item, with: .template),
                                            diameter: 40,
                                            imageColor: .white,
                                            backgroundColor: Color.BTCMap_DarkBeige)
                                .padding(.trailing, 10)
                                
                                VStack(alignment: .leading) {
                                    Text(item.osmJson.name)
                                        .font(.system(size: 14))
                                    
                                    let verifyText: String = elementViewModel.isVerified
                                    ? "\("verified".localized): \(elementViewModel.verifyText!)"
                                    : ElementViewModel.NotVerifiedTextType.short.text

                                    Text(verifyText)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .frame( maxWidth: .infinity)
                .edgesIgnoringSafeArea(.horizontal)
            }
        }
    }
}

struct CommunityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let community = CommunityPlusDistance(area: API.Area.mock!, distance: nil)
        let viewModel = CommunityDetailViewModel(communityPlusDistance: community)
        CommunityDetailView(communityDetailViewModel: viewModel)
    }
}

