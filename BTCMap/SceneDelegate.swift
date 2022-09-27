//
//  SceneDelegate.swift
//  BTCMap
//
//  Created by Vitaly Berg on 9/28/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.makeKeyAndVisible()
        window?.rootViewController = MapViewController()
    }
}
