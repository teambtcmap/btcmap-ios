//
//  CLLocationCoordinate2D+Extensions.swift
//  BTCMap
//
//  Created by salva on 4/8/23.
//

import Foundation
import CoreLocation
import GEOSwift

extension CLLocationCoordinate2D: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let latitude = try container.decode(CLLocationDegrees.self)
        let longitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    public func toPoint() -> Point {
        return Point(x: latitude, y: longitude)
    }
}
