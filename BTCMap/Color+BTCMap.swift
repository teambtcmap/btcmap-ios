//
//  Color+BTCMap.swift
//  BTCMap
//
//  Created by salva on 12/22/22.
//

import Foundation
import UIKit
import SwiftUI

extension Color {
    static var BTCMap_Green: Color { Color(UIColor.BTCMap_Green) }
    static var BTCMap_LightTeal: Color { Color(UIColor.BTCMap_LightTeal) }
    static var BTCMap_DarkBlue: Color { Color(UIColor.BTCMap_DarkBlue) }
    static var BTCMap_BackgroundBlue: Color { Color(UIColor.BTCMap_BackgroundBlue) }
    static var BTCMap_Links: Color { Color(UIColor.BTCMap_Links) }
    static var BTCMap_Background: Color { Color(UIColor.BTCMap_Background) }
    static var BTCMap_Heading: Color { Color(UIColor.BTCMap_Heading) }
    static var BTCMap_Body: Color { Color(UIColor.BTCMap_Body) }
    static var BTCMap_LightBeige: Color { Color(UIColor.BTCMap_LightBeige) }
    static var BTCMap_DarkBeige: Color { Color(UIColor.BTCMap_DarkBeige) }
    static var BTCMap_DiscordDarkBlack: Color { Color(UIColor.BTCMap_DiscordDarkBlack) }
    static var BTCMap_DiscordLightBlack: Color { Color(UIColor.BTCMap_DiscordLightBlack) }
}


extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1) {
        var chars = Array(hex.hasPrefix("#") ? hex.dropFirst() : hex[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }
        case 6: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                  green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                  blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                  alpha: alpha)
    }
}

extension UIColor {
    static var BTCMap_Green: UIColor { return UIColor(hex: "#10B981")! }
    static var BTCMap_LightTeal: UIColor { return UIColor(hex: "#53C5D5")! }
    static var BTCMap_DarkBlue: UIColor { return UIColor(hex: "#051173")! }
    static var BTCMap_BackgroundBlue: UIColor { return UIColor(hex: "#162830")! }
    static var BTCMap_Links: UIColor { return UIColor(hex: "#0891B2")! }
    static var BTCMap_Background: UIColor { return UIColor(hex: "#E4EBEC")! }
    static var BTCMap_Heading: UIColor { return UIColor(hex: "#164E63")! }
    static var BTCMap_Body: UIColor { return UIColor(hex: "#155E75")! }
    static var BTCMap_LightBeige: UIColor { return UIColor(hex: "#e0c1a3")! }
    static var BTCMap_DarkBeige: UIColor { return UIColor(hex: "#f9ba72")! }
    static var BTCMap_DiscordDarkBlack: UIColor { return UIColor(hex: "#282b30")! }
    static var BTCMap_DiscordLightBlack: UIColor { return UIColor(hex: "#36393e")! }
}
