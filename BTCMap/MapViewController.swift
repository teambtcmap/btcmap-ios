//
//  MapViewController.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/28/22.
//

import UIKit
import MapKit
import CoreLocation

class ElementAnnotation: NSObject, MKAnnotation {
    let element: API.Element
    let coordinate: CLLocationCoordinate2D
    
    init(element: API.Element) {
        self.element = element
        self.coordinate = .init(latitude: element.data.lat!, longitude: element.data.lon!)
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    private var elements: Elements!
    private var elementsQueue = DispatchQueue(label: "org.btcmap.app.map.elements")
    private var elementAnnotations: [String: ElementAnnotation] = [:]
    
    private func setupElements() {
        elements = .init(api: API())
        NotificationCenter.default.addObserver(self, selector: #selector(elementsChanged), name: Elements.changed, object: elements)
    }
    
    @objc private func elementsChanged(_ notification: Notification) {
        guard let elements = notification.userInfo?[Elements.elements] as? [API.Element] else { return }
        var annotations = elementAnnotations
        elementsQueue.async {
            var annotationsToAdd: [ElementAnnotation] = []
            var annotationsToRemove: [ElementAnnotation] = []
            
            for element in elements {
                if element.deletedAt != nil {
                    if let annotation = annotations[element.id] {
                        annotationsToRemove.append(annotation)
                        annotations.removeValue(forKey: element.id)
                    }
                } else {
                    if element.data.lat != nil, element.data.lon != nil {
                        if let annotation = annotations[element.id] {
                            annotationsToRemove.append(annotation)
                        }
                        
                        let annotation = ElementAnnotation(element: element)
                        annotationsToAdd.append(annotation)
                        annotations[element.id] = annotation
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.elementAnnotations = annotations
                self.mapView.addAnnotations(annotationsToAdd)
                self.mapView.removeAnnotations(annotationsToRemove)
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? ElementAnnotation else { return }
        let elementVC = ElementViewController()
        elementVC.element = annotation.element
        if let sheet = elementVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        present(elementVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKMarkerAnnotationView()
        marker.annotation = annotation
        return marker
    }
    
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        CLLocationManager().requestWhenInUseAuthorization()
    }
}
