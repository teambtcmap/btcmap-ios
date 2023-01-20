//
//  ImageCircle.swift
//  BTCMap
//
//  Created by salva on 1/20/23.
//

import Foundation
import SwiftUI

struct ImageCircle: View {
    let image: Image?
    let diameter: Double
    let imageColor: Color
    let backgroundColor: Color
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(backgroundColor)
                .frame(width: diameter, height: diameter)
            
            image?.foregroundColor(imageColor)
        }
    }
}
