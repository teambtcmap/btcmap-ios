//
//  RoundedPillButton.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI

struct RoundedPillButton: ButtonStyle {
    let foregroundColor: Color
    let radius: Double
    let padding: Double
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(padding)
            .foregroundColor(foregroundColor)
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
