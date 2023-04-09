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
    
    static func bounds(from coords: [CLLocationCoordinate2D]) -> Bounds {
        let minLat = coords.min(by: { $0.latitude < $1.latitude })?.latitude ?? 0
        let maxLat = coords.max(by: { $0.latitude < $1.latitude })?.latitude ?? 0
        let minLon = coords.min(by: { $0.longitude < $1.longitude })?.longitude ?? 0
        let maxLon = coords.max(by: { $0.longitude < $1.longitude })?.longitude ?? 0
        return Bounds(maxlat: maxLat, maxlon: maxLon, minlat: minLat, minlon: minLon)
    }
}

extension CLLocationDegrees {
    func toRadians() -> Double {
        return self * .pi / 180
    }
}
