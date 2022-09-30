//
//  ItemListViewState.swift
//  Harmony_Example
//
//  Created by Joan Martin on 25/7/22.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import Foundation

class ItemListViewState: ObservableObject, ItemListPresenterView {

    @Published var items: [Item]
    @Published var isLoading: Bool = true
    @Published var error: Error?
    @Published var selectedItem: Item?

    init(items: [Item] = []) {
        self.items = items
        presenter.onEventLoadList()
    }

    lazy var presenter = applicationComponent.itemComponent.itemListPresenter(view: self)

    func onDisplayProgressHud(show: Bool) {
        self.isLoading = show
    }

    func onDisplayItems(_ items: [Item]) {
        self.items = items
        self.error = nil
    }

    func onNavigateToItem(_ item: Item) {
        selectedItem = item
    }

    func onDisplayFailedToFetchItems(_ error: Error) {
        self.error = error
    }
}
