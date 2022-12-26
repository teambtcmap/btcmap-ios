//
//  CircleAnnotationView.swift
//  BTCMap
//
//  Created by salva on 12/26/22.
//

import Foundation
import UIKit
import MapKit

final class CircleAnnotationView: MKAnnotationView {
    
    private var markerView: UIView?
    private var label: UILabel?
    
    var glyphText: String? {
        didSet {
            guard let glyphText = glyphText else { return }
            let label = UILabel(frame: bounds)
            label.font = UIFont.boldSystemFont(ofSize: 10)
            label.text = glyphText
            label.textAlignment = .center
            addSubview(label)
            bringSubviewToFront(label)
            label.center = markerView?.center ?? center
            self.label = label
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label?.removeFromSuperview()
        label = nil
    }

    // MARK: Setup
    private func setupUI() {
        backgroundColor = .clear
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        circleView.layer.cornerRadius = circleView.bounds.height / 2
        circleView.clipsToBounds = true
        circleView.backgroundColor = UIColor.BTCMap_Links
        addSubview(circleView)
        bounds = circleView.bounds
        markerView = circleView
    }
}
