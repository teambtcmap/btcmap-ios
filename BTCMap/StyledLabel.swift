//
//  StyledLabel.swift
//
//  Created by Vitaly Berg on 10/7/21.
//  Copyright © 2021 Vitaly Berg. All rights reserved.
//

import UIKit

class StyledLabel: UILabel {
    @IBInspectable var lineHeight: CGFloat = 0 { didSet { setNeedsFill() } }
    @IBInspectable var kern: CGFloat = 0 { didSet { setNeedsFill() } }
    override var text: String? { didSet { setNeedsFill() } }
    override var font: UIFont! { didSet { setNeedsFill() } }
    override var textAlignment: NSTextAlignment { didSet { setNeedsFill() } }
    
    private var needsFill = false
    
    private func setNeedsFill() {
        needsFill = true
        setNeedsLayout()
    }
    
    private func fillIfNeeded() {
        guard needsFill else { return }
        fill()
    }
    
    private func fill() {
        var attributes: [NSAttributedString.Key : Any] = [:]
        if let font = font {
            attributes[.font] = font
            var offset = lineHeight - font.lineHeight
            offset = offset > 0 ? offset / 4 : offset / 2
            attributes[.baselineOffset] = offset
        }
        
        attributes[.kern] = kern
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        attributes[.paragraphStyle] = paragraphStyle
        
        attributedText = NSAttributedString(string: text ?? "", attributes: attributes)
        needsFill = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fill()
    }
    
    override func layoutSubviews() {
        fillIfNeeded()
        super.layoutSubviews()
    }
}
