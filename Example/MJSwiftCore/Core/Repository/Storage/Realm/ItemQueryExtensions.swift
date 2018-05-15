//
//  ItemQueryExtensions.swift
//  SwiftCore
//
//  Created by Joan Martin on 13/11/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import Foundation
import MJSwiftCore

extension SearchItemsQuery : RealmQuery {
    var realmPredicate : NSPredicate {
        get { return NSPredicate(format: "name CONTAINS %@", text) }
    }
}
