//
//  NoElementsView.swift
//  BTCMap
//
//  Created by Salva on 11/24/23.
//

import Foundation
import SwiftUI

struct NoElementsView: View {
    var body: some View {
        Text("no_locations".localized)
            .foregroundColor(.gray)
            .listRowSeparator(.hidden)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .padding([.top, .bottom], 30)
            .listRowBackground(Color.clear)
    }
}
