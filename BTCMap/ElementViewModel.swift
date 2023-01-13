//
//  ElementViewModel.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import Foundation
import CoreLocation

enum ElementDetailType {
    case address
    case phone
    case website
    case email
    case facebook
    case twitter
    case openingHours
    
    var displayTitle: String {
        switch self {
        case .address: return "address".localized.capitalized
        case .phone: return "phone".localized.capitalized
        case .website: return "website".localized.capitalized
        case .email: return "email".localized.capitalized
        case .facebook: return "facebook".localized.capitalized
        case .twitter: return "twitter".localized.capitalized
        case .openingHours: return "opening_hours".localized.capitalized
        }
    }
    
    var displayIconSystemName: String? {
        switch self {
        case .address: return "map.fill"
        case .phone: return "phone.fill"
        case .website: return "globe.americas.fill"
        case .email: return "envelope.fill"
        case .facebook: return nil
        case .twitter: return nil
        case .openingHours: return "clock.fill"
        }
    }
    
    var displayIconCustomName: String? {
        switch self {
        case .facebook: return "facebook"
        case .twitter: return "twitter"
        default: return nil
        }
    }
}

struct ElementViewModel {
    typealias ElementDetail = (type: ElementDetailType, title: ElementDetailTitle, value: ElementDetailValue)
    typealias ElementDetailTitle = String
    typealias ElementDetailValue = String

    let element: API.Element
    var tags: [String: String]? { element.osmJson.tags }
    
    // MARK: - Links
    var verifyLink: URL? {
        guard let name = tags?["name"],
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
    
    // MARK: - Verify
    private var surveyDates: [String] {
        var surveyDates = [String]()
        
        if let date = tags?["survey:date"] {
            surveyDates.append(date)
        }
        
        if let date = tags?["check_date"] {
            surveyDates.append(date)
        }
        
        if let date = tags?["check_date:currency:XBT"] {
            surveyDates.append(date)
        }
        
        return surveyDates
    }
    
    var isVerified: Bool { !surveyDates.isEmpty }
    
    var notVerifiedText: String { return "not_verified_by_supertaggers".localized }
    
    var verifyText: String {
        guard !surveyDates.isEmpty,
              let max = surveyDates.max() else {
            return notVerifiedText }
        
        // NOTE: These dates come back as a simple string in formate `2022-11-22`. So need to massage to work for DateFormatter.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: max) else {
            return notVerifiedText }
        
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Details (Tags)
    var name: String { tags?["name"] ?? "" }
    
    var elementDetails: [ElementDetail] {
        var details = [ElementDetail]()
        
        if !address.isEmpty {
            details.append((ElementDetailType.address, address, address))
        }
        
        if let phone = tags?["phone"] {
            details.append((ElementDetailType.phone,phone, phone))
        }
        
        if let websiteTitle = websiteTitle, let websiteUrl = websiteUrl {
            details.append((ElementDetailType.website, websiteTitle, websiteUrl))
        }
        
        if var twitter = tags?["contact:twitter"] {
            twitter = twitter
                .replacingOccurrences(of: "https://twitter.com/", with: "")
                .trimmingCharacters(in: ["@"])
            details.append((ElementDetailType.twitter, twitter, twitter))
        }
        if let facebook = tags?["contact:facebook"] {
            details.append((ElementDetailType.facebook, facebook, facebook))
        }
        if let openingHours = tags?["opening_hours"] {
            details.append((ElementDetailType.openingHours, openingHours, openingHours))
        }
        
        return details
    }
    
    var prettyPrintTags: String? {
        guard let tags = tags,
              let data = try? JSONSerialization.data(withJSONObject: tags, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else { return nil }
        
        return string
    }
    
    // MARK: Coords
    var coord: CLLocationCoordinate2D? {
        var lat: Double
        var lon: Double
        
        if element.osmJson.type == .node {
            guard let _lat = element.osmJson.lat,
                let _lon = element.osmJson.lon else { return nil }
                             
            lat = _lat
            lon = _lon
        } else {
            guard let bounds = element.osmJson.bounds else { return nil }
            
            let boundsMinLat = bounds.minlat
            let boundsMinLon = bounds.minlon
            let boundsMaxLat = bounds.maxlat
            let boundsMaxLon = bounds.maxlon
            
            lat = (boundsMinLat + boundsMaxLat) / 2.0
            lon = (boundsMinLon + boundsMaxLon) / 2.0
            print("[TUNCO] bounds - lat: \(lat) - lon: \(lon)")
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    // MARK: Details
    var address: String {
        var address = ""
        
        if let houseNumber = tags?["addr:housenumber"] {
            address += houseNumber
        }
        if let street = tags?["addr:street"] {
            if !address.isEmpty { address += " " }
            address += street
        }
        if let city = tags?["addr:city"] {
            if !address.isEmpty { address += ", " }
            address += city
        }
        if let state = tags?["addr:state"] {
            if !address.isEmpty { address += ", " }
            address += state
        }
        if let postcode = tags?["addr:postcode"] {
            if !address.isEmpty { address += ", " }
            address += postcode
        }
        
        return address
    }
    
    var websiteUrl: String? {
        return tags?["website"] ?? tags?["contact:website"]
    }
    
    var websiteTitle: String? {
        guard let website = websiteUrl else { return nil }
        return website
            .replacingOccurrences(of: "https://www.", with: "")
            .replacingOccurrences(of: "http://www.", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .trimmingCharacters(in: ["/"])
    }
}


