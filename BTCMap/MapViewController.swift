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
    
    public var markerTintColor: UIColor {
        // special case because "community_center" is the tag for Bitcoin Centers
        guard element.osmJson.tags?["amenity"] != "community_centre" else {
            return .orange
        }
        return .BTCMap_Links
    }
    
    public var priority: MKFeatureDisplayPriority {
        guard element.osmJson.tags?["amenity"] != "community_centre" else {
            return .defaultHigh
        }
        return .defaultLow
    }
}

class CommunityPolygon {
    let community: API.Area
    let polygon: MKPolygon
    
    init(community: API.Area, polygon: MKPolygon) {
        self.community = community
        self.polygon = polygon
    }
}

class MapViewController: UIViewController, MKMapViewDelegate, UISheetPresentationControllerDelegate, CLLocationManagerDelegate, ClusterManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var mapState: MapState!
    var elementsRepo: ElementsRepository!
    var areasRepo: AreasRepository!
    private var locationManager = CLLocationManager()
    private let logger = Logger(subsystem: "org.btcmap.app", category: "Map")
    private var cancellables = Set<AnyCancellable>()
    
    // Elements
    private var elementsQueue = DispatchQueue(label: "org.btcmap.app.map.elements")
    private var elementAnnotations: [String: ElementAnnotation] {
        guard let annotations = manager.annotations as? [ElementAnnotation] else { return [:] }
        return annotations.compactMap {
            return [$0.element.id : $0]
        }.reduce(into: [String: ElementAnnotation]()) { (result, dict) in
            result.merge(dict) { (_, new) in new }
        }
    }
    
    // Polygons
    private var communityPolygons: [CommunityPolygon] = []
    private var glowingOverlayRenderers: [GlowingPolygonRenderer] = []
    var onCommunityTapped: ((API.Area) -> Void)? = nil
    
    // Publishers
    let selectedElementPublisher = PassthroughSubject<API.Element, Never>()
    var deselectedElementPublisher = PassthroughSubject<API.Element, Never>()
    
    // Flags
    /// One-time to center the map on the user location on app start. Should remain false after the initial centering.
    var shouldCenterOnUserLocationAppState = true
    
    private func setupMapStateObservers() {
        // map state
        mapState.$centerCoordinate.sink(receiveValue: { [weak self] coord in
            guard let coord = coord else { return }
            self?.centerMapOnLocation(coord)
        })
        .store(in: &cancellables)
        
        mapState.$bounds.sink(receiveValue: { [weak self] bounds in
            self?.centerMapOnBounds(bounds)
        })
        .store(in: &cancellables)
        
        mapState.$style.sink(receiveValue: { [weak self] style in
            self?.changeMapStyle(style)
        })
        .store(in: &cancellables)
        
        mapState.$visibleObjects.sink(receiveValue: { [weak self] visibleObjects in
            self?.changeMapVisibleObjects(visibleObjects)
        })
        .store(in: &cancellables)
        
        // element selection
        selectedElementPublisher
           .sink { [weak self] element in
               guard let annotation = self?.elementAnnotations.first(where: { $0.0 == element.id }) else { return }
//               self?.mapView.selectAnnotation(annotation.1, animated: false)
               
               guard let coord = element.coord else { return }
//               self?.centerMapOnLocation(coord, visibleRegion: .upperHalf)
           }
           .store(in: &cancellables)

        deselectedElementPublisher
           .sink { [weak self] _ in
               if let selectedAnnotation = self?.mapView.selectedAnnotations.first {
                   self?.mapView.deselectAnnotation(selectedAnnotation, animated: true)
               }
           }
           .store(in: &cancellables)
    }
    
    private lazy var manager: ClusterManager = { [unowned self] in
        let manager = ClusterManager()
        manager.delegate = self
        return manager
    }()
    
    private func setupElements() {
        elementsRepo.$filteredItems.sink(receiveValue: { [weak self] elements in
            self?.elementsUpdated(elements)
        })
        .store(in: &cancellables)
    }
    
    private func elementsUpdated(_ elements: [API.Element]) {
        guard mapState.visibleObjects == .elements else { return }
        
        elementsQueue.async {
            let annotations = self.elementAnnotations
            let elementIds = Set(elements.map { $0.id })
            
            let annotationsToRemove = annotations.filter { !elementIds.contains($0.key) }.map { $0.value }
            let annotationsToAdd = elements.compactMap { element -> ElementAnnotation? in
                guard !annotations.keys.contains(element.id) else { return nil }
                guard element.coord?.latitude != nil && element.coord?.longitude != nil else { return nil }
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
    
    private func removeAllAnnotations() {
        manager.removeAll()
        manager.reload(mapView: mapView)
    }
    
    private func addAllAnnotations() {
        let allAnnotations = elementsRepo.filteredItems.map { ElementAnnotation(element: $0) }
        manager.add(allAnnotations)
        manager.reload(mapView: mapView)
    }
    
    // MARK: - Polygons
    private func addPolygon(_ coords: [CLLocationCoordinate2D]) {
        let polygon = MKPolygon(coordinates: coords, count: coords.count)
        mapView.addOverlay(polygon, level: .aboveLabels)
    }
    
    private func addAllPolygons() {
        communityPolygons = areasRepo.communities.compactMap { community -> CommunityPolygon? in
            guard let coords = community.unionedPolygon?.coords else { return nil }
            let polygon = MKPolygon(coordinates: coords, count: coords.count)
            return CommunityPolygon(community: community, polygon: polygon)
        }
        
        let polygons = communityPolygons.map { $0.polygon }
        mapView.addOverlays(polygons, level: .aboveLabels)
        startGlowingPolygons()
    }
    
    private func removeAllPolygons() {
        let polygonOverlays = mapView.overlays.filter { $0 is MKPolygon }
        mapView.removeOverlays(polygonOverlays)
        communityPolygons = []
    }
    
    private func startGlowingPolygons() {
        let glowDuration: TimeInterval = 4.0
        let glowSteps: CGFloat = 6
        let timeInterval = glowDuration / TimeInterval(glowSteps)
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
            let currentTime = Date().timeIntervalSince1970
            
            for glowingPolygon in self.glowingOverlayRenderers {
                let elapsedTime = currentTime.truncatingRemainder(dividingBy: glowingPolygon.randomInterval + glowDuration)
                let glowProgress = CGFloat(elapsedTime) / CGFloat(glowDuration)
                let glowAlpha = (sin(glowProgress * .pi) + 1) / 2
                
                glowingPolygon.renderer.strokeColor = glowingPolygon.randomColor.withAlphaComponent(glowAlpha)
                glowingPolygon.renderer.setNeedsDisplay()
            }
        }
    }
    
    // MARK: Random Color
    private func randomColor(alpha: CGFloat) -> UIColor {
        let red = CGFloat.random(in: 0.5...1)
        let green = CGFloat.random(in: 0.5...1)
        let blue = CGFloat.random(in: 0.5...1)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: Overlay Touches
    
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let tapPoint = gestureRecognizer.location(in: mapView)
        let tapCoordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        
        for communityPolygon in communityPolygons {
            if communityPolygon.polygon.contains(coordinate: tapCoordinate, in: mapView) {
                onTapPolygon(communityPolygon) // Closure implementation
                break
            }
        }
    }
    
    private func onTapPolygon(_ communityPolygon: CommunityPolygon) {
        mapState.selectedCommunity = communityPolygon.community
        onCommunityTapped?(communityPolygon.community)
    }
    
    // MARK: - MKMapViewDelegate


    func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {


        // 1. Cluster annotations
        if let cluster = annotation as? ClusterAnnotation {
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
        else if let annotation = annotation as? ElementAnnotation {
            selectedElementPublisher.send(annotation.element)
        }


    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? ElementAnnotation {
            UIView.animate(withDuration: 0.125, animations: {
                let scaleTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                let rotationTransform = CGAffineTransform(rotationAngle: -0.20)

                view.transform = scaleTransform.concatenating(rotationTransform)
            })

        }

    }

    func mapView(_ mapView: MKMapView, didDeselect annotation: any MKAnnotation) {
        if let annotation = annotation as? ElementAnnotation {
            self.deselectedElementPublisher.send(annotation.element)
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform.identity
        })


    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ElementAnnotation {
            let marker = mapView.dequeueReusableAnnotationView(withIdentifier: "element", for: annotation) as! MarkerAnnotationView
            marker.markerTintColor = annotation.markerTintColor
            marker.glyphImage = ElementSystemImages.systemImage(for: annotation.element, with: .alwaysTemplate)
            marker.displayPriority = annotation.priority
            return marker
        }
        else if let annotation = annotation as? ClusterAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: "cluster", for: annotation) as! CountClusterAnnotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapState.bounds = Bounds.fromMKCoordinateRegion(mapView.region)
        manager.reload(mapView: mapView)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            views.forEach { $0.alpha = 1 }
        }, completion: nil)
    }
    
    // THIS IS WITHOUT THE GLOW EFFECT
    //    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    //        if let polygon = overlay as? MKPolygon {
    //            let renderer = MKPolygonRenderer(polygon: polygon)
    //            renderer.fillColor = UIColor.clear
    //            renderer.strokeColor = randomColor(alpha: 1.0)
    //            renderer.lineWidth = 3
    //            return renderer
    //        }
    //
    //        return MKOverlayRenderer()
    //    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.lineWidth = 3
            
            let randomStrokeColor = randomColor(alpha: 1.0)
            let randomGlowInterval = TimeInterval.random(in: 1...2)
            let glowingPolygon = GlowingPolygonRenderer(renderer: renderer, randomColor: randomStrokeColor, randomInterval: randomGlowInterval)
            glowingOverlayRenderers.append(glowingPolygon)
            
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    

    // MARK: - MapView Geometry
    
    func centerMapOnUserLocation() {
        guard let location = mapView.userLocation.location else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    func centerMapOnLocation(_ coordinate: CLLocationCoordinate2D, visibleRegion: MapVisibleRegion? = .full) {
        let regionSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        var regionCenter = coordinate
        
        switch visibleRegion {
        case .upperHalf:
            let offsetLatitude = regionSpan.latitudeDelta / 3
            regionCenter = CLLocationCoordinate2D(latitude: coordinate.latitude - offsetLatitude, longitude: coordinate.longitude)
        case .full, .none:
            break
        }

        let region = MKCoordinateRegion(center: regionCenter, span: regionSpan)
        mapView.setRegion(region, animated: true)
    }

    
    func centerMapOnBounds(_ bounds: Bounds) {
        mapView.setRegion(bounds.toMKCoordinateRegion(), animated: true)
    }
    
    func changeMapStyle(_ style: MapState.MapStyle) {
        mapView.mapType = style.mapKit
    }
    
    func changeMapVisibleObjects(_ visibleObjects: MapState.MapVisibleObjects) {
        switch visibleObjects {
        case .elements:
            addAllAnnotations()
            removeAllPolygons()
        case.communities:
            removeAllAnnotations()
            addAllPolygons()
        }
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
        guard shouldCenterOnUserLocationAppState else {
            return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.centerMapOnUserLocation()
            self?.shouldCenterOnUserLocationAppState = false
        }
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
        locationManager.startUpdatingLocation()
        
        mapView.register(MarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "element")
        mapView.register(CountClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        
        userLocationButton.layer.cornerRadius = 10
        
        // TODO: Disabling temporarily because MapKit makes this difficult to move from it's top right position, which overlaps search bar
        mapView.showsCompass = false
//        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: mapEdgePadding, animated: false)

        setupElements()
        setupMapStateObservers()
        setupTapGestureRecognizer()
    }

    var mapEdgePadding = UIEdgeInsets(top: 100, left: 0, bottom: 100, right: 0)

    // MARK: - User Location Button
    @IBOutlet weak var userLocationButton: UIButton!
    @IBAction func didTapUserLocationButton(_ sender: Any) {
        centerMapOnUserLocation()
    }
}

/// Used to set a rough estimate for the the visible region of the map
enum MapVisibleRegion {
    case upperHalf
    case full
}
