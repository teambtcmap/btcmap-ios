//
//  CommunityDetailViewModel.swift
//  BTCMap
//
//  Created by salva on 1/20/23.
//

import Foundation
import CoreLocation
import SwiftUI

enum CommunityContactType: CaseIterable {
    case website
    case twitter
    case telegram
    case discord
    case youtube
    
    static var codedContacts: [CommunityContactType] { [.telegram, .discord, .twitter, .youtube, .website] }
    
    var displayIcon: Image? {
        switch self {
        case .website: return Image(systemName: "globe.americas.fill")
        case .twitter: return Image("twitter")
        case .telegram: return Image("telegram")
        case .discord: return Image("discord")
        case .youtube: return Image("youtube")
        }
    }
    
    func contact(from area: API.Area) -> String? {
        switch self {
        case .website: return area.tags.website
        case .twitter: return area.tags.twitter
        case .telegram: return area.tags.telegram
        case .discord: return area.tags.discord
        case .youtube: return area.tags.youtube
        }
    }
    
    func url(from area: API.Area) -> URL? {
        guard let contact = contact(from: area)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        switch self {
        case .website, .twitter, .telegram, .discord, .youtube: return URL(string: contact)
        default: return nil
        }
    }
}

typealias CommunityPlusDistance = (area: API.Area, distance: CLLocationDistance?)

struct CommunityDetailViewModel {
    var area: API.Area { communityPlusDistance.area }
    let communityPlusDistance: CommunityPlusDistance
    var distanceText: String? {
        guard let distance = communityPlusDistance.distance else { return nil }
        return "\(String(format: "%.1f", distance)) \("km".localized)"
    }
    
    var contacts: Array<CommunityContactType> {
        return CommunityContactType.codedContacts.filter { $0.url(from: area) != nil }
    }
}
