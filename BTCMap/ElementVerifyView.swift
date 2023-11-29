//
//  ElementVerifyView.swift
//  BTCMap
//
//  Created by salva on 1/21/23.
//

import SwiftUI

struct ElementVerifyView: View {
    @Environment(\.openURL) var openURL
    let elementViewModel: ElementViewModel
    let notVerifiedTextType: ElementViewModel.NotVerifiedTextType
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .renderingMode(.template)
                .colorMultiply(.BTCMap_LightBeige)
            Text(elementViewModel.verifyText ?? notVerifiedTextType.text)
                .lineLimit(2)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        Spacer()
        Button(action: {
            if let url = elementViewModel.hasPouchLink ? elementViewModel.payLink : elementViewModel.verifyLink {
                openURL(url)
            }        }) {
                Text((elementViewModel.hasPouchLink ? "pay" : "verify").localized)
                .padding(10)
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
                   .background(
                       RoundedRectangle(
                           cornerRadius: 6,
                           style: .continuous
                       )
                       .stroke(Color.gray, lineWidth: 1)

                   )
        }
        .controlSize(.small)
    }
}

//struct ElementVerifyView_Previews: PreviewProvider {
//    static var previews: some View {
//        ElementVerifyView()
//    }
//}
