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
    let outerDiameter: Double
    let innerDiameterScale: Double
    let imageColor: Color
    let backgroundColor: Color
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(backgroundColor)
                .frame(width: outerDiameter, height: outerDiameter)
            
            image?
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(imageColor)
                .frame(width: outerDiameter * innerDiameterScale, height: outerDiameter * innerDiameterScale, alignment: .center)
        }
    }
}
