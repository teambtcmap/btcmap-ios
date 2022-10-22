//
//  ElementDetailsItemView.swift
//  BTCMap
//
//  Created by Vitaly Berg on 10/9/22.
//

import UIKit

class ElementDetailsItemView: UIControl {
    class func makeFromNib() -> Self {
        UINib(nibName: "ElementDetailsItemView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! Self
    }
}
