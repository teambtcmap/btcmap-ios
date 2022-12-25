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
    static var BTCMap_Links: Color { Color(UIColor.BTCMap_Links) }
    static var BTCMap_Background: Color { Color(UIColor.BTCMap_Background) }
    static var BTCMap_Heading: Color { Color(UIColor.BTCMap_Heading) }
    static var BTCMap_Body: Color { Color(UIColor.BTCMap_Body) }
}


extension UIColor {
    public convenience init?(hex: String) {
           let r, g, b, a: CGFloat

           if hex.hasPrefix("#") {
               let start = hex.index(hex.startIndex, offsetBy: 1)
               let hexColor = String(hex[start...])

               if hexColor.count == 6 {
                   let scanner = Scanner(string: hexColor)
                   var hexNumber: UInt64 = 0

                   if scanner.scanHexInt64(&hexNumber) {
                       r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                       g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                       b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                       a = CGFloat(hexNumber & 0x000000ff) / 255

                       self.init(red: r, green: g, blue: b, alpha: a)
                       return
                   }
               }
           }

           return nil
       }
}

extension UIColor {
    static var BTCMap_Green: UIColor { return UIColor(hex: "#10B981")! }
    static var BTCMap_LightTeal: UIColor { return UIColor(hex: "#53C5D5")! }
    static var BTCMap_DarkBlue: UIColor { return UIColor(hex: "#051173")! }
    static var BTCMap_Links: UIColor { return UIColor(hex: "#0891B2")! }
    static var BTCMap_Background: UIColor { return UIColor(hex: "#E4EBEC")! }
    static var BTCMap_Heading: UIColor { return UIColor(hex: "#164E63")! }
    static var BTCMap_Body: UIColor { return UIColor(hex: "#155E75")! }
}
