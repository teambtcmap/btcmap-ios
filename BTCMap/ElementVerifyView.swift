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
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .renderingMode(.template)
                    .colorMultiply(.BTCMap_LightBeige)
                Text(elementViewModel.verifyText ?? notVerifiedTextType.text)
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
    }
}

//struct ElementVerifyView_Previews: PreviewProvider {
//    static var previews: some View {
//        ElementVerifyView()
//    }
//}
