//
//  SearchBar.swift
//  BTCMap
//
//  Created by salva on 4/9/23.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var backgroundColor: Color = Color.black.opacity(0.7)
    var foregroundColor: Color = .white
    
    var body: some View {
        TextField("search".localized, text: $searchText)
            .padding(14)
            .background(backgroundColor)
            .cornerRadius(28)
            .foregroundColor(foregroundColor)
            .padding(.horizontal)
    }
}
