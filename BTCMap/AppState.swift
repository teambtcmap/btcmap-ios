//
//  AppState.swift
//  BTCMap
//
//  Created by salva on 1/28/23.
//

import Foundation
import CoreLocation

final class AppState: ObservableObject {
    // Hack to pop to root/home view until apple implements a better way. Resetting Id of the Home View will cause it to refresh, and pop off the existing stack.
    @Published var homeViewId = UUID()
    @Published var mapState = MapState()
}

final class MapState: ObservableObject {
    @Published var centerCoordinate: CLLocationCoordinate2D?
    @Published var bounds: Bounds?
    
    init(centerCoordinate: CLLocationCoordinate2D? = nil, bounds: Bounds? = nil) {
        self.centerCoordinate = centerCoordinate
        self.bounds = bounds
    }
}
 
