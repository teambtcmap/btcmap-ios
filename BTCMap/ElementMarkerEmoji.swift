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
    static let healthcare = [
        "dentist": "🦷",
        "doctor": "👨‍⚕️",
        "alternative": "🌿",
        "clinic": "🩻",
        "pharmacy": "💊",
        "psychotherapist:": "👨‍⚕️",
        "hospital": "🏥",
        "physiotherapist": "👨‍⚕️",
        "counselling": "👨‍⚕️",
        "optometrist": "👁",
        "sample_collection": "🩸",
        "cosmetic_surgery": "🫦",
        "therapist": "👨‍⚕️"
    ]
    static let craft = [
        "photographer": "📸",
        "electronics_repair": "👨‍🔧",
        "electrician": "👨‍🔧",
        "painter": "👨‍🎨",
        "carpenter": "🪚",
        "sculptor": "👨‍🎨",
        "plumber": "🪠",
        "jeweller": "💎",
        "glaziery": "🪟",
        "shoemaker": "👞"
    ]
    static let company = [
        "transport": "🛤",
        "farm": "👨‍🌾"
    ]
    static let amenity = [
        "restaurant": "👨‍🍳",
        "atm": "🏧",
        "cafe": "👨‍🍳",
        "bar": "🍸",
        "bureau_de_change": "💹",
        "fast_food": "🍟",
        "bank": "🏦",
        "dentist": "🦷",
        "pub": "🍺",
        "fuel": "⛽️",
        "doctros": "👨‍⚕️",
        "pharmacy": "💊",
        "taxi": "🚕",
        "clinic": "🩻",
        "car_rental": "🚙",
        "school": "🏫",
        "veterinary": "😿",
        "ice_cream": "🍦",
        "hospital": "🏥",
        "boat_rental": "⛵️",
        "money_transfer": "💸",
        "marketplace": "🛍",
        "arts_centre": "🖼",
        "college": "🏫",
        "coworking_space": "👨‍💻",
        "car_wash": "🧽",
        "university": "🎓",
        "spa": "🧖‍♂️",
        "post_office": "🏤",
        "swingerclub": "🍆",
        "cinema": "📽",
        "bicycle_rental": "🚲",
        "theatre": "🎭",
        "recycling": "♻️",
        "library": "📚",
        "parking": "🅿️",
        "police": "👮‍♂️",
        "casino": "🎰",
        "notary": "📜",
        "dancing_school": "💃",
        "stripclub": "👯‍♀️",
        "nightclub": "🪩",
        "motorcycle_rental": "🛵",
        "payment_terminal": "🧾",
        "charging_station": "🔌",
        "training": "🏋️‍♂️",
        "bitcoin_office": "฿",
        "office": "🏢",
        "language_school": "🔤"
    ]
    static let place = [
        "farm": "👨‍🌾"
    ]
    static let leisure = [
        "park": "🌳"
    ]
    static let building = [
        "farm": "👨‍🌾",
        "church": "⛪️"
    ]
    
    static func emoji(for element: API.Element) -> String? {
        if let cuisine = element.data.tags["cuisine"] {
            return lookup(cuisine, in: Self.cuisine) ?? "👨‍🍳"
        }
        if let shop = element.data.tags["shop"] {
            return lookup(shop, in: Self.shop) ?? "🛍"
        }
        if let sport = element.data.tags["sport"] {
            return lookup(sport, in: Self.sport)
        }
        if let tourism = element.data.tags["tourism"] {
            return lookup(tourism, in: Self.tourism)
        }
        if let healthcare = element.data.tags["healthcare"] {
            return lookup(healthcare, in: Self.healthcare) ?? "⚕️"
        }
        if let craft = element.data.tags["craft"] {
            return lookup(craft, in: Self.craft)
        }
        if let amenity = element.data.tags["amenity"] {
            return lookup(amenity, in: Self.amenity)
        }
        if let place = element.data.tags["place"] {
            return lookup(place, in: Self.place)
        }
        if let leisure = element.data.tags["leisure"] {
            return lookup(leisure, in: Self.leisure)
        }
        if let building = element.data.tags["building"] {
            return lookup(building, in: Self.building)
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
