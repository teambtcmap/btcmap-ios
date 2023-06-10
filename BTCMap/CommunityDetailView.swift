//
//  CommunityDetailView.swift
//  BTCMap
//
//  Created by salva on 1/20/23.
//

import MapKit
import SwiftUI
import GEOSwift

struct CommunityDetailView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var elementsRepo: ElementsRepository
    var communityDetailViewModel: CommunityDetailViewModel
    
    @State private var filteredElements: Array<API.Element> = []
    private func filterElements() {
        guard filteredElements.isEmpty else { return }

        let filteredByArea = {
            if let polygon = communityDetailViewModel.areaWithDistance.area.unionedPolygon {
                return elementsRepo.elements(from: polygon)
            } else if let bounds = communityDetailViewModel.areaWithDistance.area.bounds  {
                return elementsRepo.elements(from: bounds)
            } else { return [] }
        }()
        
        let nonDeleted = filteredByArea.filter { $0.deletedAt.isEmpty }
                 
        filteredElements = nonDeleted.filter { !$0.osmJson.name.isEmpty }
            .sorted { (element1, element2) in
                if let surveyDate1 = element1.osmJson.latestSurveyDate,
                   let surveyDate2 = element2.osmJson.latestSurveyDate {
                    return surveyDate1 > surveyDate2
                } else if element1.osmJson.latestSurveyDate != nil {
                    return true
                } else {
                    return false
                }
            }
    }
    
    // TODO: Not verified text pink like in ElementView
    
    var body: some View {
        List {
            // MARK: - Map
            let bounds = communityDetailViewModel.areaWithDistance.area.bounds
            BoundedMapView(region: BoundedMapView.region(from: bounds ?? Bounds.zeroBounds,
                                                         padding: 0.1),
                           polygonCoords: communityDetailViewModel.areaWithDistance.area.unionedPolygon?.coords)
                .frame(height: UIScreen.main.bounds.height * 0.23)
                .frame( maxWidth: .infinity)
                .onTapGesture {
                    // hack to pop back to home. see note in AppState
                    appState.homeViewId = UUID()
                    appState.mapState.bounds = bounds
                }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            // MARK: - Contact Buttons
            VStack {
                HStack {
                    ForEach(communityDetailViewModel.contacts, id: \.self) { contact in
                        ImageCircle(image: contact.displayIcon,
                                    outerDiameter: 45,
                                    innerDiameterScale: 0.6,
                                    imageColor: .black,
                                    backgroundColor: .white)
                        .padding(4)
                        .onTapGesture {
                            guard let url = contact.url(from: communityDetailViewModel.areaWithDistance.area) else { return }
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .padding([.top, .bottom], 6)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 45)
            .listRowBackground(Color.clear)
            
            // MARK: - Elements
            if filteredElements.isEmpty {
                Text("No Locations")
                    .listRowSeparator(.hidden)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding([.top, .bottom], 6)
            }
            
            ForEach(filteredElements) { item in
                NavigationLink(destination: CommunityElementView(communityDetailViewModel: communityDetailViewModel, element: item)) {
                    
                    let elementViewModel = ElementViewModel(element: item)
                    HStack {
                        ImageCircle(image: ElementSystemImages.swiftUISystemImage(for: item, with: .template),
                                    outerDiameter: 35,
                                    innerDiameterScale: 0.6,
                                    imageColor: .black,
                                    backgroundColor: .white)
                        .padding(.trailing, 10)
                        
                        VStack(alignment: .leading) {
                            Text(item.osmJson.name)
                                .font(.system(size: 18))
                                .bold()
                            
                            elementViewModel.isVerified ?
                            Text(Image(systemName: "checkmark.seal.fill"))
                                .font(.system(size: 10))
                            + Text(" ")
                            + Text(elementViewModel.verifyText ?? "")
                                .font(.system(size: 12))
                                .foregroundColor(.gray) :
                            
                            Text(ElementViewModel.NotVerifiedTextType.short.text)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .background(Color.BTCMap_DiscordDarkBlack)
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .edgesIgnoringSafeArea(.horizontal)
        .onAppear {
            filterElements()
        }
    }
}

struct CommunityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let community = AreaWithDistance(area: API.Area.mock!, distance: nil)
        let viewModel = CommunityDetailViewModel(areaWithDistance: community)
        CommunityDetailView(communityDetailViewModel: viewModel)
    }
}

