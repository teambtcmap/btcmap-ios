//
//  Home.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI

struct Home: View {
    let mapVCWrapper = MapViewControllerWrapper()
    
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
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
