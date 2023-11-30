//
//  ElementRowView.swift
//  BTCMap
//
//  Created by salva on 11/24/23.
//

import Foundation
import SwiftUI

struct ElementRowView: View {
    let element: API.Element
    let elementViewModel: ElementViewModel
    
    init(element: API.Element) {
        self.element = element
        self.elementViewModel = ElementViewModel(element: element)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                ImageCircle(image: ElementSystemImages.swiftUISystemImage(for: element, with: .template),
                            outerDiameter: 35,
                            innerDiameterScale: 0.6,
                            imageColor: .black,
                            backgroundColor: .BTCMap_WarmWhite)
                
                if let coord = element.coord,
                   let distance = elementViewModel.distanceFromCurrentLocation(location: coord) {
                    Text(distance)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 5)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(element.osmJson.name)
                        .font(.system(size: 18))
                        .bold()
                        .foregroundColor(.BTCMap_WarmWhite)
                }
                
                elementViewModel.isVerified ?
                Text(Image(systemName: "checkmark.seal.fill"))
                    .font(.system(size: 10))
                    .foregroundColor(.BTCMap_LightTeal)
                + Text(" ")
                + Text(elementViewModel.verifyText ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.gray) :
                
                Text(ElementViewModel.NotVerifiedTextType.short.text)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 10)
        }
    }
}
