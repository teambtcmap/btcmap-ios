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
                Text(elementViewModel.name)
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
            HStack {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text(elementViewModel.verifyText)
                        .font(.subheadline)
                }
                Spacer()
                Button(action: {
                    if let url = elementViewModel.verifyLink {
                        openURL(url)
                    }
                }) {
                    Text("verify".localized.uppercased())
                }
                .buttonStyle(BorderButtonStyle(foregroundColor: .white, strokeColor: Color.gray.opacity(0.5), padding: EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)))
            }
            .padding(.bottom, 18)
            .padding(.horizontal)
            
            
            // MARK: - Details
            let details = elementViewModel.elementDetails
            if !details.isEmpty {
                ForEach(details, id: \.0) { detail in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: detail.type.displayIconSystemName)
                            Text(detail.type.displayTitle)
                                .font(.headline)
                        }
                        .padding(.bottom, 0)
                        
                        let url: URL? = {
                            switch detail.type {
                            case .phone:
                                // TODO: phone url not resolving
                                return URL(string: "tel:\(detail.value)")
                            case .website:
                                return URL(string: "\(detail.value)")
                            case .email:                      
                                return URL(string: "mailto:\(detail.value)")
                            default: return nil
                            }
                        }()
                                                
                        if let url = url {
                            Link("\(detail.value)", destination: url)
                        } else {
                            Text(detail.value)
                                .font(.subheadline)
                        }
                        
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                }
            }
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
