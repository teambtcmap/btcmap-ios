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
            
            image?
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(imageColor)
                .frame(width: diameter * 0.5, height: diameter * 0.5, alignment: .center)
        }
    }
}
