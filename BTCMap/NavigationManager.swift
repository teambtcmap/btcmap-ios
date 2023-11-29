//
//  NavigationManager.swift
//  BTCMap
//
//  Created by salva on 11/28/23.
//

import UIKit
import CoreLocation

class NavigationManager {
    static func openMapWithAddress(_ address: String) {
        let navigationOptions = createNavigationOptions(for: address)
        presentNavigationOptions(navigationOptions)
    }
    
    static func openMapWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let coordinateString = "\(coordinate.latitude),\(coordinate.longitude)"
        let navigationOptions = createNavigationOptions(for: coordinateString)
        presentNavigationOptions(navigationOptions)
    }
    
    static private func createNavigationOptions(for location: String) -> [(String, URL)] {
        let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            print("[MAP] encodedLocation: \(encodedLocation)")

        let appleURL = URL(string: "http://maps.apple.com/?q=\(encodedLocation)")!
        let googleURL = URL(string: "comgooglemaps://?q=\(encodedLocation)")!
        let wazeURL = URL(string: "https://waze.com/ul?ll=\(encodedLocation)&navigate=true")!
        
        var navigationOptions = [("Apple Maps", appleURL)]
        if UIApplication.shared.canOpenURL(googleURL) {
            navigationOptions.append(("Google Maps", googleURL))
        }
        if UIApplication.shared.canOpenURL(wazeURL) {
            navigationOptions.append(("Waze", wazeURL))
        }
        
        return navigationOptions
    }

    static private func presentNavigationOptions(_ navigationOptions: [(String, URL)]) {
        guard navigationOptions.count > 1 else {
            if let url = navigationOptions.first?.1 {
                UIApplication.shared.open(url)
            }
            return
        }
        
        let alert = UIAlertController(title: "Select Navigation App", message: nil, preferredStyle: .actionSheet)
        for option in navigationOptions {
            let action = UIAlertAction(title: option.0, style: .default) { _ in
                UIApplication.shared.open(option.1)
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        presentAlert(alert)
    }

    static private func presentAlert(_ alert: UIAlertController) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }
}
