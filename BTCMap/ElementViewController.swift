//
//  ElementViewController.swift
//  BTC Map
//
//  Created by Vitaly Berg on 9/29/22.
//

import UIKit

class ElementViewController: UIViewController {
    var element: API.Element! {
        didSet {
            if isViewLoaded {
                fill()
            }
        }
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsStackView: UIStackView!
    
    private func fill() {
        if let tags = element.osmJson.tags {
            if let name = tags["name"] {
                titleLabel.text = name
            }
            
            var details = [(String, String)]()
            
            var address = ""
            
            if let houseNumber = element.osmJson.tags?["addr:housenumber"] {
                address += houseNumber
            }
            if let street = element.osmJson.tags?["addr:street"] {
                if !address.isEmpty { address += " " }
                address += street
            }
            if let city = element.osmJson.tags?["addr:city"] {
                if !address.isEmpty { address += ", " }
                address += city
            }
            if let state = element.osmJson.tags?["addr:state"] {
                if !address.isEmpty { address += ", " }
                address += state
            }
            if let postcode = element.osmJson.tags?["addr:postcode"] {
                if !address.isEmpty { address += ", " }
                address += postcode
            }
            
            if !address.isEmpty {
                details.append(("Address", address))
            }
            
            if let phone = element.osmJson.tags?["phone"] {
                details.append(("Phone", phone))
            }
            if let website = element.osmJson.tags?["contact:website"] {
                details.append(("Website", website))
            }
            if let facebook = element.osmJson.tags?["contact:facebook"] {
                details.append(("Facebook", facebook))
            }
            if let facebook = element.osmJson.tags?["opening_hours"] {
                details.append(("Opening Hours", facebook))
            }
            
            if !details.isEmpty {
                detailsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                for (index, field) in details.enumerated() {
                    let item = ElementDetailsItemView.makeFromNib()
                    item.titleLabel.text = field.0
                    item.valueLabel.text = field.1
                    item.separatorView.isHidden = index == details.count - 1
                    detailsStackView.addArrangedSubview(item)
                }
                detailsView.isHidden = false
            } else {
                detailsView.isHidden = true
            }
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fill()
    }
}
