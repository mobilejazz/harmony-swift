//
//  UIKitMVPItemDetailViewController.swift
//  SwiftCore
//
//  Created by Joan Martin on 16/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

class UIKitMVPItemDetailViewController: UIViewController, UIKitMVPItemDetailPresenter {
    
    private var item : Item?

    var itemListView : UIKitMVPItemDetailPresenterView {
        return self.view as! UIKitMVPItemDetailPresenterView
    }
    
    override func loadView() {
        super.loadView()
        (view as! UIKitMVPItemDetailView).presenter = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = item {
            itemListView.onDisplayItem(item)
        }
    }
    
    // MARK: UIKitMVPItemDetailPresenter
    
    func onConfigureItem(_ item: Item) {
        self.title = item.name
        
        if isViewLoaded {
            itemListView.onDisplayItem(item)
        } else {
            self.item = item
        }
    }
    
}
