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

class MapViewController: UIViewController, MKMapViewDelegate, UISheetPresentationControllerDelegate {
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
        
        if let elementVC = presentedViewController as? ElementViewController {
            elementVC.element = annotation.element
            return
        }
        
        let elementVC = ElementViewController()
        elementVC.element = annotation.element
        if let sheet = elementVC.sheetPresentationController {
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            
        }
        present(elementVC, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let annotation = view.annotation as? ElementAnnotation else { return }
        guard let elementVC = presentedViewController as? ElementViewController else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if elementVC.element.id == annotation.element.id {
                self.dismiss(animated: true)
            }
        }
    }
    
    private var elementEmojis: [String: String] = [:]
    
    private func emoji(for element: API.Element) -> String? {
        if let emoji = elementEmojis[element.id] {
            return emoji
        }
        let emoji = ElementMarkerEmoji.emoji(for: element)
        elementEmojis[element.id] = emoji
        return emoji
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ElementAnnotation {
            let marker = mapView.dequeueReusableAnnotationView(withIdentifier: "element", for: annotation) as! MKMarkerAnnotationView
            marker.markerTintColor = #colorLiteral(red: 1, green: 0.555871129, blue: 0, alpha: 1)
            marker.glyphText = emoji(for: annotation.element)
            marker.displayPriority = .required
            return marker
        }
        return nil
    }
    
    // MARK: - UISheetPresentationControllerDelegate
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let annotation = mapView.selectedAnnotations.first {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "element")
        setupElements()
        CLLocationManager().requestWhenInUseAuthorization()
    }
}
