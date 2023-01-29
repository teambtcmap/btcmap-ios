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
import Combine
import Cluster

class ElementAnnotation: NSObject, MKAnnotation, Identifiable {
    let element: API.Element
    let coordinate: CLLocationCoordinate2D
    
    init(element: API.Element) {
        self.element = element
        self.coordinate = self.element.coord ?? CLLocationCoordinate2D()
    }
}

class MapViewController: UIViewController, MKMapViewDelegate, UISheetPresentationControllerDelegate, CLLocationManagerDelegate, ClusterManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var mapState: MapState!
    var elementsRepo: ElementsRepository!
    private var locationManager = CLLocationManager()
    private var elementsQueue = DispatchQueue(label: "org.btcmap.app.map.elements")
    private var elementAnnotations: [String: ElementAnnotation] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    private func setupMapStateObservers() {
        mapState.$centerCoordinate.sink(receiveValue: { [weak self] coord in
            guard let coord = coord else { return }
            self?.centerMapOnLocation(coord)
        })
        .store(in: &cancellables)
        
        mapState.$bounds.sink(receiveValue: { [weak self] bounds in
            guard let bounds = bounds else { return }
            self?.centerMapOnBounds(bounds)
        })
        .store(in: &cancellables)
    }
    
    private lazy var manager: ClusterManager = { [unowned self] in
        let manager = ClusterManager()
        manager.delegate = self
        return manager
    }()
    
    private func setupElements() {
        elementsRepo.$items.sink(receiveValue: { [weak self] elements in
              self?.elementsChanged(elements)
          })
        .store(in: &cancellables)
    }
    
    private func elementsChanged(_ elements: [API.Element]) {
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
                    if element.coord?.latitude != nil,
                       element.coord?.longitude != nil {
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
                self.addAnnotations(annotationsToAdd)
                self.removeAnnotations(annotationsToRemove)
            }
        }
    }
    
    // MARK: - Annotations
    private func addAnnotations(_ annotations: [MKAnnotation]) {
        manager.add(annotations)
        manager.reload(mapView: mapView)
    }
    
    private func removeAnnotations(_ annotations: [MKAnnotation]) {
        manager.remove(annotations)
        manager.reload(mapView: mapView)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // 1. Cluster annotations
        if let cluster = view.annotation as? ClusterAnnotation {
            var zoomRect = MKMapRect.null
            for annotation in cluster.annotations {
                let annotationPoint = MKMapPoint(annotation.coordinate)
                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
                if zoomRect.isNull {
                    zoomRect = pointRect
                } else {
                    zoomRect = zoomRect.union(pointRect)
                }
            }
            mapView.setVisibleMapRect(zoomRect, animated: true)
            return
        }
        // 2. Element annotations
        else if let annotation = view.annotation as? ElementAnnotation {
            
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ElementAnnotation {
            let marker = mapView.dequeueReusableAnnotationView(withIdentifier: "element", for: annotation) as! MarkerAnnotationView
            marker.glyphImage = ElementSystemImages.systemImage(for: annotation.element, with: .alwaysTemplate)
            marker.displayPriority = .defaultLow
            return marker
        }
        else if let annotation = annotation as? ClusterAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: "cluster", for: annotation) as! CountClusterAnnotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        manager.reload(mapView: mapView)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            views.forEach { $0.alpha = 1 }
        }, completion: nil)
    }
    
    // MARK: - MapView Geometry
    
    func centerMapOnUserLocation() {
        guard let location = mapView.userLocation.location else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    func centerMapOnLocation(_ coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    func centerMapOnBounds(_ bounds: Bounds) {
        mapView.setRegion(bounds.toMKCoordinateRegion(), animated: true)
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
        centerMapOnUserLocation()
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
        mapView.register(CountClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        
        userLocationButton.layer.cornerRadius = 10
        
        // TODO: Disabling temporarily because MapKit makes this difficult to move from it's top right position, which overlaps search bar
        mapView.showsCompass = false
        
        setupElements()
        setupMapStateObservers()
        
        locationManager.requestLocation()
    }
    
    private var firstLoad = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstLoad {
            locationManager.requestLocation()
            firstLoad = !firstLoad
        }
    }
    
    // MARK: - User Location Button
    @IBOutlet weak var userLocationButton: UIButton!
    @IBAction func didTapUserLocationButton(_ sender: Any) {
        centerMapOnUserLocation()
    }
}
