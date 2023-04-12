//
//  BoundedMap.swift
//  BTCMap
//
//  Created by salva on 1/21/23.
//

import Foundation
import SwiftUI
import MapKit

struct BoundedMapView: UIViewRepresentable {
    @State var element: API.Element?
    @State var region: MKCoordinateRegion
    @State var polygonCoords: [CLLocationCoordinate2D]?
    
    /// Computes an MKCoordinateRegion from the given bounds and applies padding.
    ///
    /// - Parameters:
    ///   - bounds: A Bounds object containing the minimum and maximum latitudes and longitudes of the region.
    ///   - padding: A value between 0 and 1, representing the percentage to pad the MKCoordinateRegion.
    /// - Returns: An MKCoordinateRegion adjusted for the specified padding.
    static func region(from bounds: Bounds, padding: Double) -> MKCoordinateRegion {
        let clampedPadding = max(min(padding, 1), 0)
        let center = CLLocationCoordinate2D(latitude: (bounds.maxlat + bounds.minlat) / 2, longitude: (bounds.maxlon + bounds.minlon) / 2)
        let latitudeDelta = (bounds.maxlat - bounds.minlat) * (1 + clampedPadding)
        let longitudeDelta = (bounds.maxlon - bounds.minlon) * (1 + clampedPadding)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        return MKCoordinateRegion(center: center, span: span)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: BoundedMapView
        
        init(_ parent: BoundedMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.strokeColor = UIColor.BTCMap_LightTeal
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        if let polygonCoords = polygonCoords {
            let polygon = MKPolygon(coordinates: polygonCoords, count: polygonCoords.count)
            mapView.addOverlay(polygon)
        }
        
        if let element = element {
            let annotation = ElementAnnotation(element: element)
            mapView.addAnnotation(annotation)
        }
    }
}
