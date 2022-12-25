//
//  RoundedPillButton.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI

struct RoundedPillButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(Color.BTCMap_LightTeal)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
