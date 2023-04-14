//
//  MKPolygon+Extensions.swift
//  BTCMap
//
//  Created by salva on 4/14/23.
//

import Foundation
import MapKit

extension MKPolygon {
    func contains(coordinate: CLLocationCoordinate2D, in mapView: MKMapView) -> Bool {
        let renderer = MKPolygonRenderer(polygon: self)
        let mapPoint = MKMapPoint(coordinate)
        let polygonViewPoint = renderer.point(for: mapPoint)
        
        return renderer.path.contains(polygonViewPoint)
    }
}
