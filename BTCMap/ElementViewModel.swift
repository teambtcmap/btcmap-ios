//
//  ElementViewModel.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import Foundation

enum ElementDetailType {
    case address
    case phone
    case website
    case email
    case facebook
    case openingHours
    
    var displayTitle: String {
        switch self {
        case .address: return "address".localized.capitalized
        case .phone: return "phone".localized.capitalized
        case .website: return "website".localized.capitalized
        case .email: return "email".localized.capitalized
        case .facebook: return "facebook".localized.capitalized
        case .openingHours: return "opening_hours".localized.capitalized
        }
    }
    
    var displayIconSystemName: String {
        switch self {
        case .address: return "map.fill"
        case .phone: return "phone.fill"
        case .website: return "globe.americas.fill"
        case .email: return "envelope.fill"
        case .facebook: return "globe"
        case .openingHours: return "clock.fill"
        }
    }
}

struct ElementViewModel {
    typealias ElementDetailValue = String
    typealias ElementDetail = (type: ElementDetailType, value: ElementDetailValue)
    
    let element: API.Element
    
    // MARK: - Links
    var verifyLink: URL? {
        guard let name = element.osmJson.tags?["name"],
              let lat = element.osmJson.lat,
              let lon = element.osmJson.lon,
              let url = "https://btcmap.org/verify-location?&name=\(name)&lat=\(lat)&long=\(lon)&\(element.osmJson.type.rawValue)=\(element.osmJson.id)".urlEncoded() else { return nil }
        
        return URL(string: url)
    }
    
    var superTaggerManualLink: URL = URL(string: "https://github.com/teambtcmap/btcmap-data/wiki/Tagging-Instructions")!
    var viewOnOSMLink: URL? {
        let id = element.id.replacingOccurrences(of: ":", with: "/")
        let string = "https://www.openstreetmap.org/\(id)"
        return URL(string: string)
    }
    var ediotOnOSMLink: URL? {
        let id = element.id.replacingOccurrences(of: ":", with: "=")
        let string = "https://www.openstreetmap.org/edit?\(id)"
        return URL(string: string)
    }
    
    
    // MARK: - Details (Tags)
    var name: String { element.osmJson.tags?["name"] ?? "" }
    
    var elementDetails: [ElementDetail] {
        var details = [ElementDetail]()
        
        var address = ""
        
        if let houseNumber = element.osmJson.tags?["addr:housenumber"] {
            address += houseNumber
        }
        if let street = element.osmJson.tags?["addr:street"] {
            if !address.isEmpty { address += " " }
            address += street
        }
        if let city = element.osmJson.tags?["addr:city"] {
            if !address.isEmpty { address += ", " }
            address += city
        }
        if let state = element.osmJson.tags?["addr:state"] {
            if !address.isEmpty { address += ", " }
            address += state
        }
        if let postcode = element.osmJson.tags?["addr:postcode"] {
            if !address.isEmpty { address += ", " }
            address += postcode
        }
        
        if !address.isEmpty {
            details.append((ElementDetailType.address, address))
        }
        
        if let phone = element.osmJson.tags?["phone"] {
            details.append((ElementDetailType.phone, phone))
        }
        if let website = element.osmJson.tags?["contact:website"] {
            details.append((ElementDetailType.website, website))
        }
        if let facebook = element.osmJson.tags?["contact:facebook"] {
            details.append((ElementDetailType.facebook, facebook))
        }
        if let openingHours = element.osmJson.tags?["opening_hours"] {
            details.append((ElementDetailType.openingHours, openingHours))
        }
        
        return details
    }
}
