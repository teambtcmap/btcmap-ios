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
                        .renderingMode(.template)
                        .colorMultiply(.BTCMap_LightBeige)
                    Text(elementViewModel.verifyText)
                        .lineLimit(2)
                        .font(.system(size: 14))
                }
                Spacer()
                Button(action: {
                    if let url = elementViewModel.verifyLink {
                        openURL(url)
                    }
                }) {
                    Text("verify".localized.uppercased())
                        .foregroundColor(Color.BTCMap_DarkBeige)
                }
                .buttonStyle(BorderButtonStyle(foregroundColor: .white, strokeColor: Color.gray.opacity(0.5), padding: EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)))
            }
            .padding(.horizontal)
                        
            
            // MARK: - Details
            VStack(alignment: .leading, spacing: 20) {
                let details = elementViewModel.elementDetails
                if !details.isEmpty {
                    ForEach(details, id: \.0) { detail in
                        HStack {
                            if let systemName = detail.type.displayIconSystemName {
                                Image(systemName: systemName).renderingMode(.template).colorMultiply(.BTCMap_LightBeige)
                            } else if let customName = detail.type.displayIconCustomName {
                                Image(customName).renderingMode(.template).colorMultiply(.BTCMap_LightBeige)
                            }
                            
                            let url: URL? = {
                                switch detail.type {
                                case .phone:
                                    // TODO: phone url not resolving with some formats
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
                                    .tint(Color.BTCMap_DarkBeige)
                            } else {
                                Text(detail.value)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .padding(.top, 40)
            .padding(.horizontal)
                        
            Spacer(minLength: 50)
            
            // MARK: - Tags JSON Dump
            if let tags = elementViewModel.prettyPrintTags {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill").renderingMode(.template).colorMultiply(.BTCMap_LightBeige)
                        Text("tags".localized)
                            .fontWeight(.bold)
                            .font(.subheadline)
                    }
                    Text(tags)
                        .font(.system(size: 12))
                }
                .padding(.horizontal)
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
