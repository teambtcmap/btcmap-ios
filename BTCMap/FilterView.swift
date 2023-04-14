//
//  FilterView.swift
//  BTCMap
//
//  Created by Lorenzo Primiterra on 16/03/23.
//

import SwiftUI

struct FilterView: View {
    @State private var isATMOn = UserDefaults.standard.bool(forKey: "showATMs")
    @State private var isBarOn = UserDefaults.standard.bool(forKey: "showBars")
    @State private var isCafeOn = UserDefaults.standard.bool(forKey: "showCafes")
    @State private var isHotelOn = UserDefaults.standard.bool(forKey: "showHotels")
    @State private var isOtherOn = UserDefaults.standard.bool(forKey: "showOthers")
    @State private var isPubOn = UserDefaults.standard.bool(forKey: "showPubs")
    @State private var isRestaurantOn = UserDefaults.standard.bool(forKey: "showRestaurants")
    @StateObject var elementsRepository = ElementsRepository(api: API())

    init() {
        UserDefaults.standard.register(defaults: ["showATMs": true])
        UserDefaults.standard.register(defaults: ["showBars": true])
        UserDefaults.standard.register(defaults: ["showCafes": true])
        UserDefaults.standard.register(defaults: ["showHotels": true])
        UserDefaults.standard.register(defaults: ["showOthers": true])
        UserDefaults.standard.register(defaults: ["showPubs": true])
        UserDefaults.standard.register(defaults: ["showRestaurants": true])
    }

    var body: some View {
            List {
                Section(header: Text("Filter Categories" )) {
                    Toggle("ATMs\(elementsRepository.items.count)", isOn: $isATMOn)
                        .onChange(of: isATMOn) { _ in
                            UserDefaults.standard.set(isATMOn, forKey: "isATMOn")
                        }
                    Toggle("Bars", isOn: $isBarOn)
                        .onChange(of: isBarOn) { _ in
                            UserDefaults.standard.set(isBarOn, forKey: "isBarOn")
                        }
                    Toggle("Cafes", isOn: $isCafeOn)
                        .onChange(of: isCafeOn) { _ in
                            UserDefaults.standard.set(isCafeOn, forKey: "isCafeOn")
                        }
                    Toggle("Hotels", isOn: $isHotelOn)
                        .onChange(of: isHotelOn) { _ in
                            UserDefaults.standard.set(isHotelOn, forKey: "isHotelOn")
                        }
                    Toggle("Other", isOn: $isOtherOn)
                        .onChange(of: isOtherOn) { _ in
                            UserDefaults.standard.set(isOtherOn, forKey: "isOtherOn")
                        }
                    Toggle("Pubs", isOn: $isPubOn)
                        .onChange(of: isPubOn) { _ in
                            UserDefaults.standard.set(isPubOn, forKey: "isPubOn")
                        }
                    Toggle("Restaurants", isOn: $isRestaurantOn)
                        .onChange(of: isRestaurantOn) { _ in
                            UserDefaults.standard.set(isRestaurantOn, forKey: "isRestaurantOn")
                        }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Filter")
        }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
