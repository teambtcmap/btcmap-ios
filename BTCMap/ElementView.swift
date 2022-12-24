//
//  SwiftUIView.swift
//  BTCMap
//
//  Created by salva on 12/23/22.
//

import SwiftUI

struct ElementView: View {
    let elementViewModel: ElementViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if let name = elementViewModel.element.osmJson.tags?["name"] {
                Text(name)
                    .font(.title)
                    .padding(.horizontal)
            }
                       
            let details = elementViewModel.elementDetails
            if !details.isEmpty {
                ForEach(details, id: \.0) { field in
                    HStack {
                        Text(field.0)
                            .font(.headline)
                        Spacer()
                        Text(field.1)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
    }
}

//struct ElementView_Previews: PreviewProvider {
//    static var previews: some View {
//        ElementView()
//    }
//}
