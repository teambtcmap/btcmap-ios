//
//  BoundedMap.swift
//  BTCMap
//
//  Created by salva on 1/21/23.
//

import Foundation
import SwiftUI
import MapKit

struct BoundedMapView: View {
    @State var element: API.Element?
    @State var region: MKCoordinateRegion
    
    private var annotations: [ElementAnnotation] {
        guard let element = element else { return [] }
        return [ElementAnnotation(element: element)] }
    
    static func region(from bounds: Bounds) -> MKCoordinateRegion {
        let center = CLLocationCoordinate2D(latitude: (bounds.maxlat + bounds.minlat) / 2, longitude: (bounds.maxlon + bounds.minlon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: bounds.maxlat - bounds.minlat, longitudeDelta: bounds.maxlon - bounds.minlon)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(Color.BTCMap_Links)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .disabled(true)        
    }
}
