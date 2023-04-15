//
//  GlowingPolygon.swift
//  BTCMap
//
//  Created by salva on 4/13/23.
//

import Foundation
import MapKit

class GlowingPolygonRenderer {
    let renderer: MKPolygonRenderer
    let randomColor: UIColor
    let randomInterval: TimeInterval

    init(renderer: MKPolygonRenderer, randomColor: UIColor, randomInterval: TimeInterval) {
        self.renderer = renderer
        self.randomColor = randomColor
        self.randomInterval = randomInterval
    }
}
