//
//  Bounds.swift
//  BTCMap
//
//  Created by salva on 1/20/23.
//

import Foundation
import MapKit
import CoreLocation

struct Bounds: Equatable {
    let maxlat: Double
    let maxlon: Double
    let minlat: Double
    let minlon: Double
    
    static var zeroBounds: Bounds { Bounds(maxlat: 0, maxlon: 0, minlat: 0, minlon: 0) }
}

extension Bounds {
    func toMKCoordinateRegion() -> MKCoordinateRegion {
        let center = CLLocationCoordinate2D(latitude: (maxlat + minlat) / 2, longitude: (maxlon + minlon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: abs(maxlat - minlat), longitudeDelta: abs(maxlon - minlon))
        return MKCoordinateRegion(center: center, span: span)
    }
    
    static func fromMKCoordinateRegion(_ region: MKCoordinateRegion) -> Bounds {
        let center = region.center
        let span = region.span

        let maxlat = center.latitude + (span.latitudeDelta / 2)
        let minlat = center.latitude - (span.latitudeDelta / 2)
        let maxlon = center.longitude + (span.longitudeDelta / 2)
        let minlon = center.longitude - (span.longitudeDelta / 2)

        return Bounds(maxlat: maxlat, maxlon: maxlon, minlat: minlat, minlon: minlon)
    }
}
