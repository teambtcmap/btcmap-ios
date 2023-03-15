//
//  ElementViewModel.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import Foundation
import CoreLocation
import SwiftUI

enum ElementDetailType {
    case address
    case phone
    case website
    case email
    case facebook
    case twitter
    case instagram
    case openingHours
    
    var displayTitle: String {
        switch self {
        case .address: return "address".localized.capitalized
        case .phone: return "phone".localized.capitalized
        case .website: return "website".localized.capitalized
        case .email: return "email".localized.capitalized
        case .facebook: return "facebook".localized.capitalized
        case .twitter: return "twitter".localized.capitalized
        case .instagram: return "instagram".localized.capitalized
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
        case .instagram: return nil
        case .openingHours: return "clock.fill"
        }
    }
    
    var displayIconCustomName: String? {
        switch self {
        case .facebook: return "facebook"
        case .twitter: return "twitter"
        case .instagram: return "instagram"
        default: return nil
        }
    }
}

struct ElementViewModel {
    typealias ElementDetail = (type: ElementDetailType, title: ElementDetailTitle, value: ElementDetailValue)
    typealias ElementDetailTitle = String
    typealias ElementDetailValue = String

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
    
    // MARK: - Verify
    private var surveyDates: [String] {
        var surveyDates = [String]()
        
        if let date = element.osmJson.tags?["survey:date"] {
            surveyDates.append(date)
        }
        
        if let date = element.osmJson.tags?["check_date"] {
            surveyDates.append(date)
        }
        
        if let date = element.osmJson.tags?["check_date:currency:XBT"] {
            surveyDates.append(date)
        }
        
        return surveyDates
    }
    
    var isVerified: Bool { !surveyDates.isEmpty }
    var verifyText: String? {
        guard !surveyDates.isEmpty,
              let max = surveyDates.max() else {
            return nil }
        
        // NOTE: These dates come back as a simple string in formate `2022-11-22`. So need to massage to work for DateFormatter.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: max) else {
            return nil }
        
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    enum NotVerifiedTextType {
        case short
        case long
        
        var text: String {
            switch self {
            case .short: return "not_verified_by_supertaggers_short".localized
            case .long: return "not_verified_by_supertaggers_long".localized
            }
        }
    }
    
    // MARK: - Details (Tags)    
    var elementDetails: [ElementDetail] {
        var details = [ElementDetail]()
        
        if !element.osmJson.address.isEmpty {
            details.append((ElementDetailType.address, element.osmJson.address, element.osmJson.address))
        }
        
        if let phone = element.osmJson.tags?["phone"] {
            details.append((ElementDetailType.phone, phone, phone))
        }
        
        if let websiteTitle = element.osmJson.websiteTitle, let websiteUrl = element.osmJson.websiteUrl {
            details.append((ElementDetailType.website, websiteTitle, websiteUrl))
        }
        
        if var twitter = element.osmJson.tags?["contact:twitter"] {
            twitter = twitter
                .replacingOccurrences(of: "https://twitter.com/", with: "")
                .trimmingCharacters(in: ["@"])
            details.append((ElementDetailType.twitter, twitter, twitter))
        }
        if var facebook = element.osmJson.tags?["contact:facebook"] {
            facebook = facebook
                .replacingOccurrences(of: "https://www.facebook.com/", with: "")
            details.append((ElementDetailType.facebook, facebook, facebook))
        }
        if var instagram = element.osmJson.tags?["contact:instagram"] {
            instagram = instagram
                .replacingOccurrences(of: "https://www.instagram.com/", with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            details.append((ElementDetailType.instagram, instagram, instagram))
        }
        if let email = element.osmJson.tags?["contact:email"] {
            details.append((ElementDetailType.email, email, email))
        }
        if let openingHours = element.osmJson.tags?["opening_hours"] {
            details.append((ElementDetailType.openingHours, openingHours, openingHours))
        }
        
        return details
    }
    
    var prettyPrintTags: String? {
        guard let tags = element.osmJson.tags,
              let data = try? JSONSerialization.data(withJSONObject: tags, options: .prettyPrinted),
              let string = String(data: data, encoding: .utf8) else { return nil }
        
        return string
    }
}


