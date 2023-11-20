//
//  MapAnnotationView.swift
//  BTCMap
//
//  Created by salva on 12/26/22.
//

import Foundation
import MapKit

enum AnnotationViewType {
    case circle
    case marker
}

class MapAnnotationView: MKAnnotationView {    
    var type: AnnotationViewType { .marker }
    private var markerImageView: UIImageView?
    private var markerView: UIView?

    private lazy var glyphLabel: UILabel = {
        let label = UILabel(frame: bounds)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        addSubview(label)
        bringSubviewToFront(label)
        let calculatedCenter: CGPoint = {
            guard let center = markerImageView?.center ?? markerView?.center else { return center }
            let offsetCenter = type == .circle ? center : CGPoint(x: center.x, y: center.y - 5) // offset for teardrop shape
            return offsetCenter
        }()
        label.center = calculatedCenter
        return label
    }()
    
    private lazy var glyphImageView: UIImageView? = {
        let frame = CGRectMake(bounds.width * 0.25, bounds.height * 0.25, bounds.width * 0.5, bounds.height / 0.5)
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        addSubview(imageView)
        bringSubviewToFront(imageView)
        let calculatedCenter: CGPoint = {
            guard let center = markerImageView?.center ?? markerView?.center else { return center }
            let offsetCenter = type == .circle ? center : CGPoint(x: center.x, y: center.y - 5) // offset for teardrop shape
            return offsetCenter
        }()
        imageView.center = calculatedCenter
        return imageView
    }()

    var glyphText: String? {
        didSet {
            guard let glyphText = glyphText else { return }
            glyphLabel.text = glyphText
        }
    }
    
    var glyphImage: UIImage? {
        didSet {
            guard let glyphImage = glyphImage else { return }
            glyphImageView?.image = glyphImage
        }
    }
    
    var markerTintColor: UIColor = .BTCMap_Links {
         didSet {
             updateMarkerTintColor()
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
                
        glyphText = nil
        glyphImage = nil
    }

    // MARK: Setup
    private func setupUI() {
        backgroundColor = .clear
        
        switch type {
        case .circle:
            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            circleView.layer.cornerRadius = circleView.bounds.height / 2
            circleView.clipsToBounds = true
            circleView.backgroundColor = UIColor.BTCMap_Links
            addSubview(circleView)
            bounds = circleView.bounds
            markerView = circleView
        case .marker:
            let image = UIImage(named: "marker")?.withTintColor(.BTCMap_Links)
            let imageView = UIImageView(image: image)
            addSubview(imageView)
            imageView.bounds = CGRectMake(imageView.bounds.minX, imageView.bounds.minY, imageView.bounds.width*2, imageView.bounds.height*2)
            bounds = imageView.bounds
            markerImageView = imageView
        }
    }
    
    private func updateMarkerTintColor() {
        guard type == .marker else { return }
        let tintedImage = UIImage(named: "marker")?.withTintColor(markerTintColor)
        markerImageView?.image = tintedImage
    }
}
