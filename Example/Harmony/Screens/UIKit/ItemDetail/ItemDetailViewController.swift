//
//  UIKitMVPItemDetailViewController.swift
//  SwiftCore
//
//  Created by Joan Martin on 16/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    // Temp item to obtain it from previous screen.
    // This could be improved.
    var item: Item?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let item = item {
            self.title = item.name

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
}
