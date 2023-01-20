//
//  SwiftUIView.swift
//  BTCMap
//
//  Created by salva on 12/23/22.
//

import SwiftUI

struct ElementView: View {
    @Environment(\.openURL) var openURL
    @State private var showingOptions = false
    
    let elementViewModel: ElementViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // MARK: - Title, Options Button
            HStack {
                Text(elementViewModel.element.osmJson.name)
                    .font(.title)
                    .padding()
                Spacer()
                Button(action: {
                    showingOptions = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                }
                .rotationEffect(.degrees(90))
                
                .confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
                    Button("supertagger_manual".localized) {
                        openURL(elementViewModel.superTaggerManualLink)
                    }
                    
                    if let url = elementViewModel.viewOnOSMLink {
                        Button("view_on_osm".localized) {
                            openURL(url)
                        }
                    }
                    
                    if let url = elementViewModel.ediotOnOSMLink {
                        Button("edit_on_osm".localized) {
                            openURL(url)
                        }
                    }
                }
            }
            
            // MARK: - Verified
            ElementVerifyView(elementViewModel: elementViewModel,
                              notVerifiedTextType: .long)
            
            // MARK: - Details
            ElementTagsView(elementViewModel: elementViewModel)            
        }
        .padding()
        .alignmentGuide(.top) { _ in 0 }
        
        Spacer()
    }
}

struct ElementView_Previews: PreviewProvider {
    static var previews: some View {
        ElementView(elementViewModel: ElementViewModel(element: API.Element.mock! ))
    }
}
