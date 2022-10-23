//
//  ElementDetailsItemView.swift
//  BTCMap
//
//  Created by Vitaly Berg on 10/9/22.
//

import UIKit

class ElementDetailsItemView: UIControl {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorHeightConstraint.constant = 1 / UIScreen.main.scale
    }
    
    class func makeFromNib() -> Self {
        UINib(nibName: "ElementDetailsItemView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! Self
    }
}
