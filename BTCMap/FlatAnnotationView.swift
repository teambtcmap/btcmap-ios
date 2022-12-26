//
//  FlatAnnotationView.swift
//  BTCMap
//
//  Created by salva on 12/26/22.
//

import Foundation
import MapKit

final class FlatAnnotationView: MKAnnotationView {
    
    private var markerImageView: UIImageView?
    private var label: UILabel?

    var glyphText: String? {
        didSet {
            guard let glyphText = glyphText else { return }
            let label = UILabel(frame: bounds)
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = glyphText
            label.textAlignment = .center
            addSubview(label)
            bringSubviewToFront(label)
            let center = markerImageView?.center ?? center
            let offsetCenter = CGPoint(x: center.x, y: center.y - 5) // offset for teardrop shape
            label.center = offsetCenter
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
        let image = UIImage(named: "marker")?.withTintColor(.BTCMap_Links)
        let imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.bounds = CGRectMake(imageView.bounds.minX, imageView.bounds.minY, imageView.bounds.width*2, imageView.bounds.height*2)
        bounds = imageView.bounds
        markerImageView = imageView
    }
}
