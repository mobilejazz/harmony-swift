//
//  ItemListPresenter.swift
//  SwiftCore
//
//  Created by Joan Martin on 03/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

protocol UIKitMVPItemListPresenter {
    func onEventSelectItem(_ item : Item)
    func onEventReloadList()
}

protocol UIKitMVPItemListPresenterView {
    func onShowProgressHud()
    func onHideProgressHud()
    
    func onDisplayItems(_ items: [Item])
}
