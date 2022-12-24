//
//  MapViewControllerWrapper.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import Foundation
import SwiftUI

struct MapViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<MapViewControllerWrapper>) -> UIViewController {
        // Return an instance of your UIKit view controller here
        let viewController = MapViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<MapViewControllerWrapper>) {
    }
}
