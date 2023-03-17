//
//  OptionsView.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI

struct OptionsView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var areasRepo: AreasRepository

    @State private var showingOptions = false
    @State private var showingSettings = false
    @State private var showingCommunities = false
    @State private var showingDonate = false
    @State private var showingFilter = false
    @State private var showingNotImplementedAlert = false
    
    var dismissElementView: (() -> Void)?
    
    var body: some View {
        HStack {
            // MARK: - Donate Button
            NavigationLink(destination: CommunitiesView(), isActive: $showingCommunities) {
                Button(action: {
                    dismissElementView?()
                    showingFilter = true
                }) {
                    Image("filter")
                        .foregroundColor(.white)
                }
            }
            
            NavigationLink(destination: CommunitiesView(), isActive: $showingCommunities) {
                Button(action: {
                    dismissElementView?()
                    showingCommunities = true
                }) {
                    Image("btc_logo")
                        .foregroundColor(.white)
                }
            }

            // MARK: - Options Button
            Button(action: {
                dismissElementView?()
                showingOptions = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
            }
            .rotationEffect(.degrees(90))
            .confirmationDialog("Options", isPresented: $showingOptions, titleVisibility: .hidden) {
                Button("communities".localized) {
                    showingCommunities = true
                }
                
                Button("add_place".localized) {
                    openURL(URL(string: "https://btcmap.org/add-location")!)
                }
                
                Button("donate".localized) {
                    showingDonate = true
                }
         
                
                // TODO: Hide for now until implemented
//                Button("trends".localized) {
//                    // TODO: Implement
//                    showingNotImplementedAlert = true
//                }
//
//                Button("top_supertaggers".localized) {
//                    // TODO: Implement
//                    showingNotImplementedAlert = true
//                }
//
//                Button("latest_changes".localized) {
//                    // TODO: Implement
//                    showingNotImplementedAlert = true
//                }

                Button("settings".localized) {
                    showingSettings = true
                }
            }
            // TODO: Temp
            .alert("Not yet implemented.", isPresented: $showingNotImplementedAlert) {
                Button("OK", role: .cancel) { }
            }
            
            NavigationLink(destination: DonateView(), isActive: $showingDonate) { }
            NavigationLink(destination: SettingsView(), isActive: $showingSettings) { }
            NavigationLink(destination: FilterView(), isActive: $showingFilter) { }
        }
        .background(Color.clear)
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}
