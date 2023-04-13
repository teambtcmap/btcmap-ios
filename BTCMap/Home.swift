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
    
    @State private var searchText = ""
    func searchTextChanged(to text: String) {
        elementsRepository.searchStringDidChange(text)
    }
    
    func injectMapVCWrapper() {
        mapVCWrapper.mapViewController.mapState = appState.mapState
        mapVCWrapper.mapViewController.elementsRepo = elementsRepository
    }
    var mapVCWrapper = MapViewControllerWrapper()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                let _ = injectMapVCWrapper()
                mapVCWrapper
                    .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    HStack {
                        SearchBar(searchText: $searchText, backgroundColor: .clear)
                            .onChange(of: searchText) { newValue in
                                searchTextChanged(to: newValue)
                            }
                        OptionsView(dismissElementView: mapVCWrapper.mapViewController.dismissElementDetail)
                    }
                    .padding(.trailing, 20)
                }
                .zIndex(100)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.black.opacity(0.4))
                .cornerRadius(28)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationBarHidden(true).navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .id(appState.homeViewId)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(appState)
        .environmentObject(areasRepository)
        .environmentObject(elementsRepository)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
