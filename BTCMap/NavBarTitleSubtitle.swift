//
//  NavBarTitleSubtitle.swift
//  BTCMap
//
//  Created by salva on 1/20/23.
//

import Foundation
import SwiftUI

struct NavBarTitleSubtitle: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(title)
                .fontWeight(.bold)
                .font(.title)
                .shadow(color: .black, radius: 2, x: 0, y: 2)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding([.leading, .trailing, .top], 10)

            Text(subtitle)
                .font(.headline)
                .shadow(color: .black, radius: 1.5, x: 0, y: 1.5)
        }
    }
}
