//
//  ElementTagsView.swift
//  BTCMap
//
//  Created by salva on 1/21/23.
//

import SwiftUI

struct ElementTagsView: View {
    @Environment(\.openURL) var openURL
    let elementViewModel: ElementViewModel
    
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
                                                
                        let url: URL? = {
                            switch detail.type {
                            case .phone:
                                let phone:String = detail.value.replacingOccurrences(of: " ", with: "", options: .regularExpression)
                                return URL(string: "tel://\(phone)")
                            case .website:
                                return URL(string: "\(detail.value)")
                            case .email:
                                return URL(string: "mailto:\(detail.value)")
                            case .facebook:
                                print(detail.value)
                                return URL(string: "https://www.facebook.com/\(detail.value)")
                            case .instagram:
                                print(detail.value)
                                return URL(string: "https://www.instagram.com/\(detail.value)")
                            case .twitter:
                                print(detail.value)
                                return URL(string: "https://twitter.com/\(detail.value)")
                            //The case .address: is handled in the next if block
                            default: return nil
                            }
                        }()

                        VStack(alignment: .leading) {                            
                            if detail.type == .address {
                                Button(action: {
                                    openMapButtonAction(address: detail.value)
                                }) {
                                    Text(detail.title)
                                        .foregroundColor(Color.BTCMap_DarkBeige)
                                        .font(.system(size: 16, weight: .medium))
                                        .multilineTextAlignment(.leading)
                                }
                            } else if let url = url {
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
                                .foregroundColor(.white.opacity(0.9))
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
                                        .foregroundColor(.white)
                                }
                            }
                          
                        }

                    }
                    .padding(.top, 30)
                }
            }
        }
    }
    
    func openMapButtonAction(address: String) {
        let appleURL = "http://maps.apple.com/?q=\(address)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let googleURL = "comgooglemaps://?q=\(address)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let wazeURL = "waze://ul?q=\(address)&navigate=false".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let googleItem = ("Google Maps", URL(string:googleURL)!)
        let wazeItem = ("Waze", URL(string:wazeURL)!)
        var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]

        if UIApplication.shared.canOpenURL(googleItem.1) {
            installedNavigationApps.append(googleItem)
        }

        if UIApplication.shared.canOpenURL(wazeItem.1) {
            installedNavigationApps.append(wazeItem)
        }

        guard installedNavigationApps.count > 1 else {
            if let (_, url) = installedNavigationApps.first {
                openURL(url)
            }
            return
        }
        
        let alert = UIAlertController(title: "select_navigation_app".localized, message:nil , preferredStyle: .actionSheet)
        for app in installedNavigationApps {
            let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                print(app.1)
                openURL(app.1)
            })
            alert.addAction(button)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        if var topController = UIApplication.shared.keyWindow?.rootViewController  {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }

}

//struct ElementTagsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ElementTagsView()
//    }
//}
