//
//  Home.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI

struct Home: View {
    @StateObject var appState = AppState()
    // TODO: Add to AppState?
    @StateObject var areasRepository = AreasRepository(api: API())
    @StateObject var elementsRepository = ElementsRepository(api: API())
    
    // MARK: - Layers Button
    @State private var areLayersButtonsVisible = false
    @State private var mapStyleSelected: MapLayersButtons = .topo
    @State private var mapObjectsSelected: MapLayersButtons = .elements
    
    // MARK: - Search
    @State private var searchText = ""
    func searchTextChanged(to text: String) {
        elementsRepository.searchStringDidChange(text)
    }
    
    // MARK: - CommunityDetail
    @State private var showCommunityDetail = false

    private func communityDetailView() -> CommunityDetailView? {
        if let community = appState.mapState.selectedCommunity {
            let viewModel = CommunityDetailViewModel(areaWithDistance: AreaWithDistance(area: community))
            return CommunityDetailView(communityDetailViewModel: viewModel)
        }
        return nil
    }
    
    // MARK: - MapViewVC Wrapper
    func injectMapVCWrapper() {
        mapVCWrapper.mapViewController.mapState = appState.mapState
        mapVCWrapper.mapViewController.elementsRepo = elementsRepository
        mapVCWrapper.mapViewController.areasRepo = areasRepository
        mapVCWrapper.mapViewController.onCommunityTapped = { _ in
            self.showCommunityDetail.toggle()
        }
    }
    var mapVCWrapper = MapViewControllerWrapper()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                let _ = injectMapVCWrapper()
                mapVCWrapper
                    .edgesIgnoringSafeArea(.all)
                
                // Search bar
                HStack {
                    SearchBar(searchText: $searchText, backgroundColor: .clear)
                        .onChange(of: searchText) { newValue in
                            searchTextChanged(to: newValue)
                        }
                    
                    OptionsView(dismissElementView: mapVCWrapper.mapViewController.dismissElementDetail)
                        .padding(.trailing, 20)
                }
                .zIndex(100)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.black.opacity(0.4))
                .cornerRadius(28)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Bottom-left layers buttons
                Button(action: {
                    areLayersButtonsVisible.toggle()
                }) {
                    Image(systemName: "square.3.stack.3d.top.filled")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(.black).opacity(0.8)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20) // note: hardcoded to match the insets of the userLocationButton, which is in storyboard
                .padding(.leading, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                
                // this is the pop-up button view
                if areLayersButtonsVisible {
                    LayersButtonsView(mapStyleSelected: $mapStyleSelected,
                                      mapObjectsSelected: $mapObjectsSelected,
                                      closure0: { appState.mapState.style = .topo },
                                      closure1: { appState.mapState.style = .satellite },
                                      closure2: { appState.mapState.visibleObjects = .elements },
                                      closure3: { appState.mapState.visibleObjects = .communities },
                                      hideButtons: { areLayersButtonsVisible.toggle() })
                    .padding(.bottom, 85)
                    .padding(.leading, 30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
                
                // Bottom-right user location button is in the Map storyboard (legacy)
            }
            .navigationBarHidden(true).navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .id(appState.homeViewId)
            
            // Community Detail sheet
            .sheet(isPresented: $showCommunityDetail, content: {
                // TODO: - understand why this is called 5 times on each $showCommunityDetail value changes
                if let communityDetailView = communityDetailView() {
                    NavigationView {
                        communityDetailView
                    }
                    .onDisappear() {
                        appState.mapState.selectedCommunity = nil
                    }
                }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(appState)
        .environmentObject(areasRepository)
        .environmentObject(elementsRepository)
        .accentColor(.white)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
