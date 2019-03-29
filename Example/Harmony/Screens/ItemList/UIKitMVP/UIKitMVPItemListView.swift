//
//  ItemListView.swift
//  SwiftCore
//
//  Created by Joan Martin on 03/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit
import Kingfisher

class UIKitMVPItemListView: UIView, UIKitMVPItemListPresenterView, UITableViewDataSource, UITableViewDelegate {
    
    var presenter: UIKitMVPItemListPresenter?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var items : [Item] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 68
    }
    
    // MARK: IBActions
    
    @IBAction func onReloadAction(_ sender: Any) {
        presenter?.onEventReloadList()
    }
    
    // MARK: ItemListPresenterView
    
    func onShowProgressHud() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
    }
    
    func onHideProgressHud() {
        activityIndicator.stopAnimating()
        tableView.isHidden = false
    }
    
    func onDisplayItems(_ items: [Item]) {
        self.items = items
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCellIdentifier", for: indexPath) as! ItemCell
        
        let item = items[indexPath.row]
        
        cell.itemNameLabel.text = item.name
        cell.itemCountLabel.text = "\(item.count) units"
        cell.itemPriceLabel.text = "\(item.price)€"
        
        if let imageURL = item.imageURL {
            cell.itemImageView.kf.setImage(with: imageURL)
        } else {
            cell.itemImageView.image = nil
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.onEventSelectItem(items[indexPath.row])
    }
}
