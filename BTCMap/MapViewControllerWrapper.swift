//
//  MapViewControllerWrapper.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import Foundation
import SwiftUI

struct MapViewControllerWrapper: UIViewControllerRepresentable {
    let mapViewController = MapViewController()
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MapViewControllerWrapper>) -> UIViewController {
        return mapViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<MapViewControllerWrapper>) {
    }
}
