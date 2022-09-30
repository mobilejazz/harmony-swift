//
//  ItemListPresenter.swift
//  Harmony_Example
//
//  Created by Joan Martin on 22/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Harmony

protocol ItemListPresenterView: AnyObject {
    func onDisplayProgressHud(show: Bool)

    func onDisplayItems(_ items: [Item])
    func onNavigateToItem(_ item: Item)
    func onDisplayFailedToFetchItems(_ error: Error)
}

protocol ItemListPresenter {
    func onEventLoadList()
    func onActionSelected(item: Item)
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
        view?.onDisplayProgressHud(show: true)
        getItems.execute().then { items in
            self.view?.onDisplayProgressHud(show: false)
            self.view?.onDisplayItems(items)
        }.fail { error in
            self.view?.onDisplayProgressHud(show: false)
            self.view?.onDisplayFailedToFetchItems(error)
        }
    }

    func onActionSelected(item: Item) {
        view?.onNavigateToItem(item)
    }

    func onActionReloadList() {
        view?.onDisplayProgressHud(show: true)
        getItems.execute(MainSyncOperation()).then { items in
            self.view?.onDisplayProgressHud(show: false)
            self.view?.onDisplayItems(items)
        }.fail { error in
            self.view?.onDisplayProgressHud(show: false)
            self.view?.onDisplayFailedToFetchItems(error)
        }
    }
}
