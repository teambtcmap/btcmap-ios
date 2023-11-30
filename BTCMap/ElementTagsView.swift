//
//  ElementTagsView.swift
//  BTCMap
//
//  Created by salva on 1/21/23.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}

struct ShareText: Identifiable {
    let id = UUID()
    let text: String
}

struct ElementTagsView: View {
    @Environment(\.openURL) var openURL
    let elementViewModel: ElementViewModel
    
    @State var shareText: ShareText?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            let details = elementViewModel.elementDetails
            if !details.isEmpty {
                ForEach(details, id: \.0) { detail in
                    HStack {
                        if let systemName = detail.type.displayIconSystemName {
                            Image(systemName: systemName).renderingMode(.template).colorMultiply(.BTCMap_LightBeige)
                        } else if let customName = detail.type.displayIconCustomName {
                            Image(customName).renderingMode(.template).colorMultiply(.BTCMap_LightBeige)
                        }
                                                                        
                        VStack(alignment: .leading) {                            
                            if detail.type == .address {
                                Button(action: {
                                    NavigationManager.openMapWithAddress(detail.value)
                                }) {
                                    Text(detail.title)
                                        .foregroundColor(Color.BTCMap_DarkBeige)
                                        .font(.system(size: 16, weight: .medium))
                                        .multilineTextAlignment(.leading)
                                }
                            } else if let url = url(detail: detail) {
                                Button(action: {
                                    openURL(url)
                                }) {
                                    Text(detail.title)
                                        .foregroundColor(Color.BTCMap_DarkBeige)
                                        .font(.system(size: 16, weight: .medium))
                                        .multilineTextAlignment(.leading)                         
                                }
                            } else {
                                Text(detail.value)
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                    }
                }
            }
            
            // MARK: - Directions + Share
            HStack(alignment: .center, spacing: 20) {
                if let coord = elementViewModel.element.coord {
                    Button(action: {
                        NavigationManager.openMapWithCoordinate(coord)
                    }) {
                        Text("directions".localized)
                            .padding(16)
                            .font(.system(size: 18))
                            .foregroundColor(.BTCMap_LightTeal)
                               .background(
                                   RoundedRectangle(
                                       cornerRadius: 8,
                                       style: .continuous
                                   )
                                   .stroke(Color.BTCMap_LightTeal, lineWidth: 1)

                               )
                    }
                    .controlSize(.large)

                    Button(action: {
                        if let link = elementViewModel.shareLink {
                            shareText = ShareText(text: link.absoluteString)
                        }
                    }) {
                        Text("share".localized)
                            .padding(16)
                            .font(.system(size: 18))
                            .foregroundColor(.BTCMap_LightTeal)
                               .background(
                                   RoundedRectangle(
                                       cornerRadius: 8,
                                       style: .continuous
                                   )
                                   .stroke(Color.BTCMap_LightTeal, lineWidth: 1)
                               )
                    }
                    .controlSize(.large)
                }
            }
            .padding(.top, 40)
            .sheet(item: $shareText) { shareText in
                       ActivityView(text: shareText.text)
                   }
    
            // MARK: - Tags Dump
            let isShowTagsOn = UserDefaults.standard.bool(forKey: "isShowTagsOn")
            if(isShowTagsOn){
                if let tags = elementViewModel.element.osmJson.tags {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "list.bullet.circle.fill").renderingMode(.template).colorMultiply(.BTCMap_LightBeige)
                            Text("tags".localized)
                                .fontWeight(.bold)
                                .font(.subheadline)
                                .foregroundColor(.BTCMap_WarmWhite)
                        }
                        ForEach(Array(tags.keys), id: \.self) { key in
                            HStack {
                                if let value = tags[key]{
                                    Text("\(key)")
                                        .fontWeight(.bold)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Text(value)
                                        .font(.system(size: 12))
                                        .foregroundColor(.BTCMap_WarmWhite)
                                }
                            }
                          
                        }

                    }
                    .padding(.top, 50)
                }
            }
        }
    }
    
    func url(detail: ElementViewModel.ElementDetail) -> URL? {
        switch detail.type {
        case .phone:
            let phone:String = detail.value.replacingOccurrences(of: " ", with: "", options: .regularExpression)
            return URL(string: "tel://\(phone)")
        case .website:
            return URL(string: "\(detail.value)")
        case .email:
            return URL(string: "mailto:\(detail.value)")
        case .facebook:
            return URL(string: "https://www.facebook.com/\(detail.value)")
        case .instagram:
            return URL(string: "https://www.instagram.com/\(detail.value)")
        case .twitter:
            return URL(string: "https://twitter.com/\(detail.value)")
        case .address:
            //The case .address: handled by `openMapButtonAction()`
            return nil
        default: return nil
        }
    }
}

//struct ElementTagsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ElementTagsView()
//    }
//}
