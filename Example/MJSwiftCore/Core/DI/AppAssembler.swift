//
//  AppAssembler.swift
//  SwiftCore
//
//  Created by Joan Martin on 31/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Swinject

class AppAssembler {
    static let assembler : Assembler = Assembler([StorageAssembly(),
                                                  NetworkAssembly(),
                                                  DataProviderAssembly(),
                                                  InteractorAssembly()])
    
    static var resolver : Resolver {
        return assembler.resolver
    }
}
