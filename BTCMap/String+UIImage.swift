//
//  String+UIImage.swift
//  BTCMap
//
//  Created by salva on 12/26/22.
//

import Foundation
import UIKit

extension String {
    func toImage() -> UIImage? {
          let size = CGSize(width: 20, height: 20)
          UIGraphicsBeginImageContextWithOptions(size, false, 0)
          UIColor.white.set()
          let rect = CGRect(origin: .zero, size: size)
          UIRectFill(CGRect(origin: .zero, size: size))
          (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 20)])
          let image = UIGraphicsGetImageFromCurrentImageContext()
          UIGraphicsEndImageContext()
          return image
      }
}
