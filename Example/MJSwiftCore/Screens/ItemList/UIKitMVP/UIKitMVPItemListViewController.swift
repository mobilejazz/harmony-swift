//
//  ViewController.swift
//  SwiftCore
//
//  Created by Joan Martin on 13/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import MJSwiftCore
//import RealmSwift

class UIKitMVPItemListViewController: UIViewController, UIKitMVPItemListPresenter {

    var itemListView : UIKitMVPItemListPresenterView {
        return self.view as! UIKitMVPItemListPresenterView
    }
    
    override func loadView() {
        super.loadView()
        (view as! UIKitMVPItemListView).presenter = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadItems(.storageSync)
    }
    
    private func loadItems(_ operation: MJSwiftCore.Operation) {
        let getItemsInteractor = AppAssembler.resolver.resolve(GetItemsInteractor.self)!
        
        self.itemListView.onShowProgressHud()
        getItemsInteractor.execute(operation).inMainQueue().then(success: { (items) in
            self.itemListView.onHideProgressHud()
            self.itemListView.onDisplayItems(items!)
        }, failure: { (error) in
            self.itemListView.onHideProgressHud()
            self.onDisplayError(error)
        })
    }
    
    private func onDisplayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: ItemListPresenter
    
    func onEventSelectItem(_ item: Item) {
        performSegue(withIdentifier: "segue.item.detail", sender: item)
    }
    
    func onEventReloadList() {
        loadItems(.networkSync)
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue.item.detail" {
            let detailPresenter = segue.destination as! UIKitMVPItemDetailPresenter
            let item = sender as! Item
            
            detailPresenter.onConfigureItem(item)
        }
    }
}
