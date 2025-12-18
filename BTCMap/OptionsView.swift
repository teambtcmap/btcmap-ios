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

    @Binding var showingOptions: Bool

    @State private var showingConfDialog = false
    @State private var showingSettings = false
    @State private var showingCommunities = false
    @State private var showingDonate = false
    @State private var showingNotImplementedAlert = false
    
    var body: some View {
        HStack {
            // MARK: - Communities Button
            NavigationLink(
                destination: CommunitiesView(),
                isActive: $showingCommunities) {
                Button(action: {
                    showingCommunities = true
                }) {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.white)
                }
            }
            
            // MARK: - Options Button
            Button(action: {
                showingConfDialog = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
            }
            .rotationEffect(.degrees(90))
            .confirmationDialog("options".localized, isPresented: $showingConfDialog, titleVisibility: .hidden) {

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

                Button("cancel".localized, role: .cancel) {
                    showingConfDialog = false
                }
            }
            // TODO: Temp
            .alert("Not yet implemented.", isPresented: $showingNotImplementedAlert) {
                Button("OK", role: .cancel) { }
            }
            
            NavigationLink(destination: DonateView(), isActive: $showingDonate) { }
            NavigationLink(destination: SettingsView(), isActive: $showingSettings) { }
        }
        .background(Color.clear)
        .onChange(
            of: showingConfDialog || showingSettings || showingCommunities || showingDonate,
            perform: { isItShowingOptions in
                showingOptions = isItShowingOptions
            })
    }

}
