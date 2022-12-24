//
//  ElementViewModel.swift
//  BTCMap
//
//  Created by salva on 12/24/22.
//

import Foundation

struct ElementViewModel {
    typealias ElementTitle = String
    typealias ElementValue = String
    typealias ElementDetail = (ElementTitle, ElementValue)

    let element: API.Element
    
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
            details.append(("Address", address))
        }
        
        if let phone = element.osmJson.tags?["phone"] {
            details.append(("Phone", phone))
        }
        if let website = element.osmJson.tags?["contact:website"] {
            details.append(("Website", website))
        }
        if let facebook = element.osmJson.tags?["contact:facebook"] {
            details.append(("Facebook", facebook))
        }
        if let facebook = element.osmJson.tags?["opening_hours"] {
            details.append(("Opening Hours", facebook))
        }
        
        return details
    }
}
