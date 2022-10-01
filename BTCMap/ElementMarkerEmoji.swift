//
//  ElementMarkerEmoji.swift
//  BTCMap
//
//  Created by Vitaly Berg on 10/1/22.
//

import Foundation

struct ElementMarkerEmoji {
    static let sport = [
        "fitness": "💪",
        "crossfit": "💪",
        "yoga": "🧘‍♂️", // 🧘‍♀️🧘🧘‍♂️
        "equestrian": "🏇", // 🐴🐎🎠🏇
        "scuba_diving": "🤿",
        "paragliding": "🪂",
        "parachuting": "🪂",
        "shooting": "🔫",
        "climbing": "🧗‍♂️", // 🧗‍♀️🧗🧗‍♂️
        "soccer": "⚽️", // ⚽️🏟🥅
        "football": "⚽️",
        "darts": "🎯",
        "billiards": "🎱",
        "surfing": "🏄‍♂️", // 🏄‍♀️🏄🏄‍♂️
        "skateboard": "🛹",
        "jiu-jitsu": "🥋", // 🤼‍♀️🤼🤼‍♂️🥋
        "golf": "⛳️", // ⛳️🏌️‍♀️🏌️‍♂️🏌️
        "cycling": "🚴‍♂️",
        "tennis": "🎾",
    ]
    static let cuisine = [
        "wok": "🥡",
        "sushi": "🍣",
        "burger": "🍔",
        "hot_dog": "🌭",
        "pizza": "🍕",
        "coffee_shop": "☕️",
        "coffee": "☕️",
        "chicken": "🍗",
        "italian": "🍝",
        "sandwich": "🥪",
        "japanese": "🍱",
        "curry": "🍛",
        "raw_food": "🥑",
        "organic": "🥦",
        "american": "🥓",
        "crepe": "🥞",
        "kebab": "🥙",
        "juice": "🥤",
        "ice_cream": "🍨",
        "barbecue": "🍖",
        "dessert": "🍮",
        "donut": "🍩",
        "doughnut": "🍩",
        "noodle": "🍜",
        "pasta": "🍝",
        "bakery": "🍰",
        "snacks": "🥠",
        "cupcake": "🧁",
        "bagel": "🥯",
        "bagel_shop": "🥯",
        "russian": "🥟",
        "steak_house": "🥩",
        "steak": "🥩",
        "chinese": "🥢",
        "thai": "🍛",
        "asian": "🍙",
        "mexican": "🌯",
        "breakfast": "🍳",
    ]
    static let shop = [
        "computer": "💻",
        "clothes": "👗", // 🧢👙🧤🧣👗👚🥋👖🧥👕👔🧦👘🥻🩲🩳🦺🩱🥼
        "jewelry": "💍",
        "hairdresser": "💇‍♂️", // 💇‍♀️💇💇‍♂️
        "yes": "🛍",
        "electronics": "🖥",
        "supermarket": "🏪",
        "beauty": "💄",
        "car_repair": "👨‍🔧", // 👩‍🔧🧑‍🔧👨‍🔧
        "books": "📚",
        "convenience": "🏪",
        "furniture": "🛋",
        "travel_agency": "🧳", // 🗺
        "gift": "🎁",
        "mobile_phone": "📱",
        "car": "🚗",
        "tobacco": "🚬",
        "bakery": "🍰",
        "bicycle": "🚲",
        "massage": "💆‍♂️",
        "florist": "💐",
        "e-cigarette": "🚬",
        "optician": "👓",
        "photo": "📷",
        "farm": "👨‍🌾",
        "sports": "🏅",
        "music": "🎸",
        "art": "🖼",
        "shoes": "👟",
        "wine": "🍷",
        "hardware": "⚙️",
        "car_parts": "⚙️",
        "toys": "🧸",
        "cannabis": "☘️",
        "alcohol": "🥃",
        "pet": "🐶",
        "kiosk": "🏪",
        "laundry": "🧺",
        "pastry": "🥮",
        "cosmetics": "🧴",
        "coffee": "☕️",
        "beverages": "🧋",
        "stationery": "📎",
        "department_store": "🏬",
        "chocolate": "🍫",
        "scuba_diving": "🤿",
        "video": "📼",
        "motorcycle": "🏍",
        "seafood": "🦞",
        "surf": "🏄‍♂️",
        "grocery": "🛒"
    ]
    static let tourism = [
        "hotel": "🏨",
        "apartment": "🏠",
        "chalet": "🛖",
        "camp_site": "🏕",
        "motel": "🏩",
        "apartments": "🏠",
        "guest_house": "🏘",
        "hostel": "🛏",
        "attraction": "🎡",
        "artwork": "🖼",
        "information": "ℹ️",
    ]
    
    static func emoji(for element: API.Element) -> String? {
        if let amenity = element.data.tags["amenity"] {
            if amenity == "restaurant" || amenity == "cafe" || amenity == "fast_food" {
                if let cuisine = element.data.tags["cuisine"] {
                    if let emoji = lookup(cuisine, in: Self.cuisine) {
                        return emoji
                    }
                }
                return "👨‍🍳"
            }
            
            switch amenity {
            case "restaurant": return "👨‍🍳"
            case "atm": return "🏧" // 💵 💴 💶 💷 💳
            case "cafe": return "👨‍🍳"
            case "bar": return "🍸" // 🍾 🥂 🍻 🍷 🍺 🥃 🍸 🍹 🍶
            case "bureau_de_change": return "💹" // 💱 💹
            case "fast_food": return "🍕" // 🍕 🍔 🌮 🍟 🌭
            case "bank": return "🏦"
            case "dentist": return "🦷"
            case "pub": return "🍺"
            case "fuel": return "⛽️"
            case "doctros": return "👨‍⚕️" // 🩺 🩻 🥼 👩‍⚕️ 🧑‍⚕️ 👨‍⚕️
            case "pharmacy": return "💊" // 💉 💊
            case "taxi": return "🚕" // 🚖 🚕
            case "clinic": return "🩺" // 🏥
            case "car_rental": return "🚙" // 🚗 🚙 🏎 🚘
            case "school": return "🏫" // 🏫👩‍🏫🧑‍🏫👨‍🏫
            case "spa": return "🧖‍♂️"
            case "cinema": return "📽" // 🎥🎞📽🎦
            case "bicycle_rental": return "🚲" // 🚴‍♀️🚴🚴‍♂️🚲🚵‍♀️🚵🚵‍♂️
            case "theatre": return "🎭"
            case "recycling": return "♻️"
            case "spa,_sauna": return "🧖‍♂️" // 🧖‍♀️🧖🧖‍♂️
            case "library": return "📚"
            case "parking": return "🅿️"
            case "police": return "👮‍♂️" // 🚨 🚔 👮‍♀️ 👮 👮‍♂️ 🚓
            case "casino": return "🎰"
            default:
                return nil
            }
        }
        if let shop = element.data.tags["shop"] {
            return lookup(shop, in: Self.shop)
        }
        if let sport = element.data.tags["sport"] {
            return lookup(sport, in: Self.sport)
        }
        if let tourism = element.data.tags["tourism"] {
            return lookup(tourism, in: Self.tourism)
        }
        if let cuisine = element.data.tags["cuisine"] {
            return lookup(cuisine, in: Self.cuisine)
        }
        return nil
    }
    
    static func lookup(_ value: String, in map: [String: String]) -> String? {
        let components = value.lowercased().components(separatedBy: ";")
        for component in components {
            if let emoji = map[component] {
                return emoji
            }
        }
        return nil
    }
}
