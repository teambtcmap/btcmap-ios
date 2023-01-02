//
//  DonateView.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct DonateView: View {
    @Environment(\.openURL) var openURL
    
    let btc = "bc1qyyr7g9tew6sfa57mv2r6rvgj2ucakcmqnqzqjj"
    let ln = "LNURL1DP68GURN8GHJ7ERZXVUXVER9X4SNYTNY9EMX7MR5V9NK2CTSWQHXJME0D3H82UNVWQHKZURF9AMRZTMVDE6HYMP0XYA8GEF9"
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Text("donate_headline".localized)
                    .font(.title2)
                
                Image("btc_address")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 240, height: 240)
                
                HStack {
                    Button(action: {
                        openURL(URL(string: "bitcoin:\(btc)")!)
                    }) {
                        Text("pay".localized)
                    }
                    .buttonStyle(RoundedPillButton(foregroundColor: .black, backgroundColor: .BTCMap_DarkBeige, radius: 24, padding: 16))
                    .padding(.trailing, 10)
                    
                    Button(action: {
                        UIPasteboard.general.setValue(btc, forPasteboardType: UTType.plainText.identifier)
                    }) {
                        Text("copy_btc_address".localized)
                    }
                    .buttonStyle(RoundedPillButton(foregroundColor: .black, backgroundColor: .BTCMap_DarkBeige, radius: 24, padding: 16))
                    .padding(.trailing, 10)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                Image("lnurl")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 240, height: 240)
                
                HStack {
                    Button(action: {
                        openURL(URL(string: "lightning:\(ln)")!)
                    }) {
                        Text("pay".localized)
                    }
                    .buttonStyle(RoundedPillButton(foregroundColor: .black, backgroundColor: .BTCMap_DarkBeige, radius: 24, padding: 16))
                    .padding(.trailing, 10)
                    
                    Button(action: {
                        UIPasteboard.general.setValue(ln, forPasteboardType: UTType.plainText.identifier)
                    }) {
                        Text("copy_lnurl".localized)
                    }
                    .buttonStyle(RoundedPillButton(foregroundColor: .black, backgroundColor: .BTCMap_DarkBeige, radius: 24, padding: 16))
                    .padding(.trailing, 10)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
        }
        .navigationBarHidden(false)
        .navigationTitle("donate".localized)
    }
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
