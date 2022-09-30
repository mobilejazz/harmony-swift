//
//  ItemCell.swift
//  SwiftCore
//
//  Created by Joan Martin on 06/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import Kingfisher
import UIKit

class ItemCell: UITableViewCell {
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var itemPriceLabel: UILabel!

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
