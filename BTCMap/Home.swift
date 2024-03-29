//
//  Home.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI
import Combine

struct Home: View {
    @StateObject var appState = AppState()
    @ObservedObject private var viewModel: HomeViewModel

    // MARK: - Layers Button
    @State private var areLayersButtonsVisible = false
    @State private var mapStyleSelected: MapLayersButtons = .topo
    @State private var mapObjectsSelected: MapLayersButtons = .elements
    
    // MARK: - Search
    @State private var searchText = ""
    func searchTextChanged(to text: String) {
        appState.elementsRepository.searchStringDidChange(text)
    }
    
    // MARK: - Sheets
    @State private var activeSheet: ActiveSheet? = .mainList {
        didSet {
            if activeSheet == .mainList { currentMainListDetent = PresentationDetent.fraction(0.1) }
            
            isMainListSheetPresented = (activeSheet == .mainList)
            
            //HACK: This is added on a delay because for some reason the element detail and community detail sheets, when presented, didn't animate. Probably the dismissal of .mainList sheet interferred with animation.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isElementDetailSheetPresented = (activeSheet == .elementDetail)
                isCommunityDetailSheetPresented = (activeSheet == .communityDetail)
            }
        }
    }
    
    @State private var isMainListSheetPresented = false
    @State private var isElementDetailSheetPresented = false
    @State private var isCommunityDetailSheetPresented = false
    
    @State private var currentMainListDetent: PresentationDetent = .fraction(0.1)
    
    
    // MARK: - MapViewVC Wrapper
    func injectMapVCWrapper() {
        mapVCWrapper.mapViewController.mapState = appState.mapState
        mapVCWrapper.mapViewController.elementsRepo = appState.elementsRepository
        mapVCWrapper.mapViewController.areasRepo = appState.areasRepository
        mapVCWrapper.mapViewController.onCommunityTapped = { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                activeSheet = .communityDetail
            }
        }
    }
    var mapVCWrapper = MapViewControllerWrapper()
    
    init() {
        viewModel = HomeViewModel(mapViewController: mapVCWrapper.mapViewController)
    }
    
    
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
                .padding(.bottom, 100) // note: hardcoded to match the insets of the userLocationButton, which is in storyboard
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
                    .padding(.bottom, 165)
                    .padding(.leading, 30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
                
                // Bottom-right user location button is in the Map storyboard (legacy)
            }
            .navigationBarHidden(true).navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .id(appState.homeViewId)
                        
            // Sheets
            .onAppear {
                activeSheet = .mainList
            }
            .onReceive(viewModel.$selectedElement) { element in
                if element != nil {
                    activeSheet = .elementDetail
                }
            }
            .onReceive(viewModel.$deselectedElement) { element in
                if element != nil {
                    activeSheet = .mainList
                }
            }
            
            // Sheet for Main List
            .sheet(isPresented: $isMainListSheetPresented) {
                ElementsListView() { element in 
                    self.mapVCWrapper.mapViewController.selectedElementPublisher.send(element)
                }
                .presentationDetents([.fraction(0.1), .fraction(0.4), .large],
                                     selection: $currentMainListDetent)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
            }

            // Sheet for Element Detail
            .sheet(isPresented: $isElementDetailSheetPresented) {
                if let selectedElement = viewModel.selectedElement {
                    ElementView(element: selectedElement)
                        .presentationDetents([.medium])
                        .presentationBackgroundInteraction(.enabled)
                        .onDisappear() {
                            self.mapVCWrapper.mapViewController.deselectedElementPublisher.send(selectedElement)
                            activeSheet = .mainList
                        }
                }

            }

            // Sheet for Community Detail
            .sheet(isPresented: $isCommunityDetailSheetPresented) {
                if let community = appState.mapState.selectedCommunity {
                    let viewModel = CommunityDetailViewModel(areaWithDistance: AreaWithDistance(area: community))
                    NavigationView {
                        CommunityDetailView(communityDetailViewModel: viewModel)
                            .presentationBackgroundInteraction(.enabled)
                            .onDisappear() {
                                appState.mapState.selectedCommunity = nil
                                activeSheet = .mainList
                            }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(appState)
        .accentColor(.white)
    }
}

enum ActiveSheet: Identifiable {
    case mainList, elementDetail, communityDetail, none

    var id: Int {
        self.hashValue
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
