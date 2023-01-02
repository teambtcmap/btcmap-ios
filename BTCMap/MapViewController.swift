//
//  MapViewController.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/28/22.
//

import UIKit
import MapKit
import CoreLocation
import SwiftUI

class ElementAnnotation: NSObject, MKAnnotation {
    let element: API.Element
    let coordinate: CLLocationCoordinate2D
    
    init(element: API.Element) {
        self.element = element
        self.coordinate = .init(latitude: element.osmJson.lat!, longitude: element.osmJson.lon!)
    }
}

class MapViewController: UIViewController, MKMapViewDelegate, UISheetPresentationControllerDelegate, CLLocationManagerDelegate {    
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager = CLLocationManager()
    
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
                if !element.deletedAt.isEmpty {
                    if let annotation = annotations[element.id] {
                        annotationsToRemove.append(annotation)
                        annotations.removeValue(forKey: element.id)
                    }
                } else {
                    if element.osmJson.lat != nil, element.osmJson.lon != nil {
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
        
        // deselect current annotationView if different
        if let elementVC = presentedViewController as? UIHostingController<ElementView>,
           elementVC.rootView.elementViewModel.element.id != annotation.element.id {
            self.dismiss(animated: true)
        }
        
        // show new annotationView
        let elementViewModel = ElementViewModel(element: annotation.element)
        let elementDetailHostedVC = UIHostingController(rootView: ElementView(elementViewModel: elementViewModel))
        if let sheet = elementDetailHostedVC.sheetPresentationController {
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            
        }
        present(elementDetailHostedVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let annotation = view.annotation as? ElementAnnotation else { return }
        guard let elementVC = presentedViewController as? UIHostingController<ElementView> else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if elementVC.rootView.elementViewModel.element.id  == annotation.element.id {
                self.dismiss(animated: true)
            }
        }
    }
    
    private var elementImages: [String: UIImage] = [:]
    
    private func image(for element: API.Element) -> UIImage? {
        if let image = elementImages[element.id] {
            return image
        }
        let image = ElementSystemImages.systemImage(for: element)
        elementImages[element.id] = image
        return image
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ElementAnnotation {
            let marker = mapView.dequeueReusableAnnotationView(withIdentifier: "element", for: annotation) as! MarkerAnnotationView
            marker.glyphImage = image(for: annotation.element)
            marker.displayPriority = .defaultHigh
            marker.clusteringIdentifier = "element"
            return marker
        }
        else if let cluster = annotation as? MKClusterAnnotation {
            let marker = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster", for: cluster) as! CircleAnnotationView
            marker.glyphText = String(cluster.memberAnnotations.count)
            return marker
        }
        return nil
    }

    // MARK: - MapView Geometry
    
    private func centerMapOnUserLocation(for mapView: MKMapView) {
        guard let location = mapView.userLocation.location else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - CLLocationManager Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
        default:
            mapView.showsUserLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Implement
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerMapOnUserLocation(for: mapView)
    }
    

    // MARK: - UISheetPresentationControllerDelegate
    // NOTE: This is a bit of hack to allow SwiftUI Views to dismiss the presented hosted ElementView. Can implement a more elegant solution whebn MapVC is converted to SwiftUI
    lazy var dismissElementDetail: () -> Void = { [weak self] in        
        self?.dismiss(animated: true)
        if let annotation = self?.mapView.selectedAnnotations.first {
            self?.mapView.deselectAnnotation(annotation, animated: true)
        }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let annotation = mapView.selectedAnnotations.first {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

        mapView.register(MarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "element")
        mapView.register(CircleAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")

        userLocationButton.layer.cornerRadius = 10
        
        // TODO: Disabling temporarily because MapKit makes this difficult to move from it's top right position, which overlaps search bar
        mapView.showsCompass = false
        
        setupElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.requestLocation()
    }
    
    // MARK: - User Location Button
    @IBOutlet weak var userLocationButton: UIButton!
    @IBAction func didTapUserLocationButton(_ sender: Any) {
        centerMapOnUserLocation(for: mapView)
    }
}
