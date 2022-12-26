//
//  OptionsView.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI

struct OptionsView: View {
    @Environment(\.openURL) var openURL
    @State private var showingOptions = false
    @State private var showingDonate = false
    @State private var showingNotImplementedAlert = false
    
    var body: some View {
        HStack {
            // MARK: - Donate Button
            NavigationLink(destination: DonateView(), isActive: $showingDonate) {
                Button(action: {
                    showingDonate = true
                }) {
                    Image("btc_logo")
                        .foregroundColor(.white)
                }
            }
            
            // MARK: - Options Button
            Button(action: {
                showingOptions = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
            }
            .rotationEffect(.degrees(90))

            .confirmationDialog("Options", isPresented: $showingOptions, titleVisibility: .hidden) {
                Button("add_place".localized) {
                    openURL(URL(string: "https://btcmap.org/add-location")!)
                }
                Button("communities".localized) {
                    // TODO: Implement
                    showingNotImplementedAlert = true
                }
                Button("trends".localized) {
                    // TODO: Implement
                    showingNotImplementedAlert = true
                }
                Button("top_supertaggers".localized) {
                    // TODO: Implement
                    showingNotImplementedAlert = true
                }
                Button("latest_changes".localized) {
                    // TODO: Implement
                    showingNotImplementedAlert = true
                }
                Button("settings".localized) {
                    // TODO: Implement
                    showingNotImplementedAlert = true
                }
            }
            
            // TODO: Temp
            .alert("Not yet implemented.", isPresented: $showingNotImplementedAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.7))
        .cornerRadius(28)
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}
