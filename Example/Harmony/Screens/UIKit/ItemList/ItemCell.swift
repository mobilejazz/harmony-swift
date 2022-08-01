//
//  ItemCell.swift
//  SwiftCore
//
//  Created by Joan Martin on 06/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit
import Kingfisher

class ItemCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        itemImageView.kf.cancelDownloadTask()
    }
}
