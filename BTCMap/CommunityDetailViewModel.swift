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
    
    // NOTE: Only website and twitter coded right now
    static var codedContacts: [CommunityContactType] { [.website, .twitter] }
    
    var displayIcon: Image? {
        switch self {
        case .website: return Image(systemName: "globe.americas.fill")
        case .twitter: return Image("twitter")
        case .telegram: return nil
        case .discord: return nil
        case .youtube: return nil
        }
    }
    
    func contact(from area: API.Area) -> String? {
        switch self {
        case .website: return area.tags.website
        case .twitter: return area.tags.twitter
        case .telegram: return nil
        case .discord: return area.tags.discord
        case .youtube: return nil
        }
    }
    
    func url(from area: API.Area) -> URL? {
        guard let contact = contact(from: area) else { return nil }
        
        switch self {
        case .website: return URL(string: contact)
        case .twitter: return URL(string: contact)
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
