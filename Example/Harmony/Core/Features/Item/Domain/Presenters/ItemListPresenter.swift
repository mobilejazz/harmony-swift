//
//  ItemListPresenter.swift
//  Harmony_Example
//
//  Created by Joan Martin on 22/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Harmony

protocol ItemListPresenterView: class {
    func onShowProgressHud()
    func onHideProgressHud()
    
    func onDisplay(items: [Item])
    func onNavigateTo(item: Item)
    func onDisplayFailedToFetchItems(_ error: Error)
}

protocol ItemListPresenter {
    func onEventLoadList()
    func onActionSelected(item : Item)
    func onActionReloadList()
}

class ItemListDefaultPresenter: ItemListPresenter {
    private weak var view: ItemListPresenterView?
    private let getItems: GetAllItemsInteractor
    
    init(_ view: ItemListPresenterView, _ getItems: GetAllItemsInteractor) {
        self.view = view
        self.getItems = getItems
    }
    
    func onEventLoadList() {
        view?.onShowProgressHud()
        getItems.execute().then { items in
            self.view?.onHideProgressHud()
            self.view?.onDisplay(items: items)
        }.fail { error in
            self.view?.onHideProgressHud()
            self.view?.onDisplayFailedToFetchItems(error)
        }
    }
    
    func onActionSelected(item: Item) {
        view?.onNavigateTo(item: item)
    }
    
    func onActionReloadList() {
        view?.onShowProgressHud()
        self.getItems.execute(MainSyncOperation()).then { items in
            self.view?.onHideProgressHud()
            self.view?.onDisplay(items: items)
        }.fail { error in
            self.view?.onHideProgressHud()
            self.view?.onDisplayFailedToFetchItems(error)
        }
    }
}
