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
import os

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
    private var elementAnnotations: [String: ElementAnnotation] {
        guard let annotations = manager.annotations as? [ElementAnnotation] else { return [:] }
        return annotations.compactMap {
            return [$0.element.id : $0]
        }.reduce(into: [String: ElementAnnotation]()) { (result, dict) in
            result.merge(dict) { (_, new) in new }
        }
    }
    
    private let logger = Logger(subsystem: "org.btcmap.app", category: "Map")

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
              self?.elementsUpdatedFromAPI(elements)
          })
        .store(in: &cancellables)
        
        elementsRepo.$filteredItems.sink(receiveValue: { [weak self] elements in
              self?.elementsUpdatedFromSearch(elements)
          })
        .store(in: &cancellables)
    }
    
    private func elementsUpdatedFromAPI(_ elements: [API.Element]) {
        elementsQueue.async {
            let annotations = self.elementAnnotations
            var annotationsToAdd: [ElementAnnotation] = []
            var annotationsToRemove: [ElementAnnotation] = []
            
            for element in elements {
                if !element.deletedAt.isEmpty {
                    if let annotation = annotations[element.id] {
                        annotationsToRemove.append(annotation)
                    }
                } else {
                    if element.coord?.latitude != nil,
                       element.coord?.longitude != nil {
                        if let annotation = annotations[element.id] {
                            annotationsToRemove.append(annotation)
                        }
                        
                        let annotation = ElementAnnotation(element: element)
                        annotationsToAdd.append(annotation)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.logger.log("elementsUpdatedFromAPI - adding: \(annotationsToAdd.count) - removing: \(annotationsToRemove.count)")
                self.removeThenAddAnnotations(remove: annotationsToRemove, add: annotationsToAdd)
            }
        }
    }
    
    private func elementsUpdatedFromSearch(_ elements: [API.Element]) {
        elementsQueue.async {
            let annotations = self.elementAnnotations
            let elementIds = Set(elements.map { $0.id })
            
            let annotationsToRemove = annotations.filter { !elementIds.contains($0.key) }.map { $0.value }
            let annotationsToAdd = elements.compactMap { element -> ElementAnnotation? in
                guard !annotations.keys.contains(element.id) else { return nil }
                return ElementAnnotation(element: element)
            }

            DispatchQueue.main.async {
                self.logger.log("elementsUpdatedFromSearch - adding: \(annotationsToAdd.count) - removing: \(annotationsToRemove.count)")
                self.removeThenAddAnnotations(remove: annotationsToRemove, add: annotationsToAdd)
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
    
    private func removeThenAddAnnotations(remove: [MKAnnotation]?, add: [MKAnnotation]?) {
        if let remove = remove { manager.remove(remove) }
        if let add = add { manager.add(add) }
        self.logger.log("removeThenAddAnnotations - remove: \(remove != nil ? remove!.count : 0) - then add: \(add != nil ? add!.count : 0) ")
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
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = false

        mapView.register(MarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "element")
        mapView.register(CountClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        
        userLocationButton.layer.cornerRadius = 10
        
        // TODO: Disabling temporarily because MapKit makes this difficult to move from it's top right position, which overlaps search bar
        mapView.showsCompass = false
        
        setupElements()
        setupMapStateObservers()
    }
    
    // MARK: - User Location Button
    @IBOutlet weak var userLocationButton: UIButton!
    @IBAction func didTapUserLocationButton(_ sender: Any) {
        centerMapOnUserLocation()
    }
}
