//
//  Bounds.swift
//  BTCMap
//
//  Created by salva on 1/20/23.
//

import Foundation

struct Bounds: Equatable {
    let maxlat: Double
    let maxlon: Double
    let minlat: Double
    let minlon: Double
    
    static var zeroBounds: Bounds { Bounds(maxlat: 0, maxlon: 0, minlat: 0, minlon: 0) }
}
