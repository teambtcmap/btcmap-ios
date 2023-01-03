//
//  BorderButtonStyle.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI

struct BorderButtonStyle: ButtonStyle {
    let foregroundColor: Color
    let strokeColor: Color
    let padding: EdgeInsets
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(padding)
            .foregroundColor(foregroundColor)
            //.background(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
}
