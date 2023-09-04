//
//  SettingsView.swift
//  BTCMap
//
//  Created by Lorenzo Primiterra on 13/03/23.
//

import SwiftUI

struct SettingsView: View {
    // Theme switch state
    //@State private var isThemedPinsOn = UserDefaults.standard.bool(forKey: "isThemedPinsOn")

    // Dark maps switch state
    //@State private var isDarkMapsOn = UserDefaults.standard.bool(forKey: "isDarkMapsOn")

    // Show tags switch state
    @State private var isShowTagsOn = UserDefaults.standard.bool(forKey: "isShowTagsOn")

    init() {
        // Set default true for isShowTagsOn
        UserDefaults.standard.register(defaults: ["isShowTagsOn": true])
    }
    
    var body: some View {
        List {
            Section {
                /*
                 * TODO: Implement in the future
                 Toggle("themed_pins".localized, isOn: $isThemedPinsOn)
                    .onChange(of: isThemedPinsOn) { _ in
                        UserDefaults.standard.set(isThemedPinsOn, forKey: "isThemedPinsOn")
                    }
                Toggle("dark_map".localized, isOn: $isDarkMapsOn)
                    .onChange(of: isDarkMapsOn) { _ in
                        UserDefaults.standard.set(isDarkMapsOn, forKey: "isDarkMapsOn")
                    }
                 */
                Toggle("show_tags".localized, isOn: $isShowTagsOn)
                    .onChange(of: isShowTagsOn) { _ in
                        UserDefaults.standard.set(isShowTagsOn, forKey: "isShowTagsOn")
                    }
                /*
                NavigationLink(destination: DonateView()) {
                    Text("connect_osm_account".localized)
                }
                 */
            }
            .listRowBackground(Color.BTCMap_DiscordDarkBlack)
        }
        .listStyle(.plain)
        .background(Color.BTCMap_DiscordLightBlack)
        .navigationBarTitle("settings".localized)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
