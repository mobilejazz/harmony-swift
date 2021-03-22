//
//  ViewController.swift
//  SwiftCore
//
//  Created by Joan Martin on 13/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit
import Harmony

class ItemListViewController: UIViewController, ItemListPresenterView, UITableViewDataSource, UITableViewDelegate {

    lazy var presenter = applicationComponent.itemComponent.itemListPresenter(view: self)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var items : [Item] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onEventLoadList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 68
    }
    
    @IBAction func reloadButtonAction(_ sender: Any) {
        presenter.onActionReloadList()
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
    
    func onDisplay(items: [Item]) {
        self.items = items
        tableView.reloadData()
    }
    
    func onNavigateTo(item: Item) {
        performSegue(withIdentifier: "segue.item.detail", sender: item)
    }
    
    func onDisplayFailedToFetchItems(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue.item.detail" {
            let detailPresenter = segue.destination as! ItemDetailViewController
            let item = sender as! Item
            
            detailPresenter.item = item
        }
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
        presenter.onActionSelected(item: items[indexPath.row])
    }
}
