//
//  UIKitMVPItemDetailView.swift
//  SwiftCore
//
//  Created by Joan Martin on 16/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit
import Kingfisher

class UIKitMVPItemDetailView: UIView, UIKitMVPItemDetailPresenterView {
    
    var presenter: UIKitMVPItemDetailPresenter?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    // MARK: UIKitMVPItemDetailPresenterView
    
    func onDisplayItem(_ item: Item) {
        nameLabel.text = item.name
        unitsLabel.text = "\(item.count) units"
        priceLabel.text = "\(item.price)€"
        
        if let imageURL = item.imageURL {
            imageView.kf.setImage(with: imageURL)
        } else {
            imageView.image = nil
        }
    }
}
