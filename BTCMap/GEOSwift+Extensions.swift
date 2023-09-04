//
//  GEOSwift+Extensions.swift
//  BTCMap
//
//  Created by salva on 4/9/23.
//

import Foundation
import GEOSwift
import CoreLocation

extension Polygon {
    var coords: [CLLocationCoordinate2D] {
        return exterior.points.map { CLLocationCoordinate2D(latitude: $0.x, longitude: $0.y) }
    }
}

extension Point {
    var coord: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: x, longitude: y) }
}
