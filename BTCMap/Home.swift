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
    
    func injectMapVCWrapper() {
        mapVCWrapper.mapViewController.mapState = appState.mapState
        mapVCWrapper.mapViewController.elementsRepo = elementsRepository
    }
    
    var mapVCWrapper = MapViewControllerWrapper()

    var body: some View {
        NavigationView {            
            ZStack(alignment: .topTrailing) {
                let _ = injectMapVCWrapper()
                mapVCWrapper
                    .edgesIgnoringSafeArea(.all)
                
                OptionsView(dismissElementView: mapVCWrapper.mapViewController.dismissElementDetail)
                    .zIndex(100)
                    .offset(x: -20, y: 30)
                    .overlay(Color.clear)
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
