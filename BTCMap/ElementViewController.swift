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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagsTextView: UITextView!
    
    private func fill() {
        if let name = element.data.tags["name"] {
            titleLabel.text = name
        }
        /*
        if let description = element.data.tags["description"] {
            descriptionLabel.text = description
        }
         */
        
        if let data = try? JSONSerialization.data(withJSONObject: element.data.tags, options: .prettyPrinted) {
            tagsTextView.text = String(data: data, encoding: .utf8)
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fill()
       
        
        
    }
}
