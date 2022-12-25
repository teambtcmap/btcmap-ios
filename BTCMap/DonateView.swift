//
//  DonateView.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import SwiftUI

struct DonateView: View {
    var body: some View {
        VStack {
            Text("donate_headline".localized)
                .font(.title2)
            
            HStack {
                Button(action: {
                    // TODO: Deeplink wallet
                }) {
                    Text("pay".localized)
                }
                .buttonStyle(RoundedPillButton())
                
                Button(action: {
                    // TODO: Copy address
                }) {
                    Text("copy_btc_address".localized) 
                }
                .buttonStyle(RoundedPillButton())
            }
            
            HStack {
                Button(action: {
                    // TODO: Deeplink wallet
                }) {
                    Text("pay".localized)
                }
                .buttonStyle(RoundedPillButton())

                Button(action: {
                    // TODO: Copy address
                }) {
                    Text("copy_lnurl".localized)
                }
                .buttonStyle(RoundedPillButton())
            }
        }
        .navigationTitle("donate".localized)
    }
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
