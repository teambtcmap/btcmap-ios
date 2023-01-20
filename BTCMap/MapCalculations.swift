//
//  MapCalculations.swift
//  BTCMap
//
//  Created by salva on 1/20/23.
//

import Foundation
import CoreLocation

struct MapCalculations {
    static func haversineDistance(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6371.0
        let dLat = (coord2.latitude - coord1.latitude).toRadians()
        let dLon = (coord2.longitude - coord1.longitude).toRadians()
        let lat1 = coord1.latitude.toRadians()
        let lat2 = coord2.latitude.toRadians()
        let a = sin(dLat/2) * sin(dLat/2) +
                sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return earthRadius * c
    }
}

extension CLLocationDegrees {
    func toRadians() -> Double {
        return self * .pi / 180
    }
}
