//
//  Home.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI

struct Home: View {
    // TODO: Inject all these from SceneDelegate?
    @StateObject var areasRepository = AreasRepository(api: API())
    @StateObject var elementsRepository = ElementsRepository(api: API())

    var mapVCWrapper = MapViewControllerWrapper()
    
    var body: some View {
        NavigationView {            
            ZStack(alignment: .topTrailing) {
                mapVCWrapper
                    .edgesIgnoringSafeArea(.all)
                
                OptionsView(dismissElementView: mapVCWrapper.mapViewController.dismissElementDetail)
                    .zIndex(100)
                    .offset(x: -20, y: 30)
                    .overlay(Color.clear)
            }
            .navigationBarHidden(true).navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(areasRepository)
        .environmentObject(elementsRepository)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
