//
//  AppAssembler.swift
//  SwiftCore
//
//  Created by Joan Martin on 31/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit
import MJSwiftCore
import Swinject

class AppAssembler {
    static let assembler : Assembler = Assembler([RealmAssembly(),
                                                  NetworkAssembly(),
                                                  ItemAssembly()])
    
    static var resolver : Resolver {
        return assembler.resolver
    }
}

// Make Vastra compliant with ObjectValidation
extension VastraService : ObjectValidation { }
