//
//  UIKitMVPItemDetailPresenter.swift
//  SwiftCore
//
//  Created by Joan Martin on 16/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

protocol UIKitMVPItemDetailPresenter {
    func onConfigureItem(_ item: Item)
}

protocol UIKitMVPItemDetailPresenterView {
    func onDisplayItem(_ item: Item)
}
