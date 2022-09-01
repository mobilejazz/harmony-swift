//
//  ApplicationProvider.swift
//  Harmony_Example
//
//  Created by Joan Martin on 22/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Harmony
import Alamofire

// Enabling vastra service as an object validation
extension VastraService: ObjectValidation {}

protocol ApplicationComponent {
    var itemComponent: ItemComponent { get }
}

class ApplicationDefaultModule: ApplicationComponent {
    
    private lazy var logger: Logger = DeviceConsoleLogger()
    private lazy var backgroundExecutor: Executor = DispatchQueueExecutor()
    
    private lazy var apiClient: Session = {
        // Alamofire Session Manager
        let sessionManager = Session(interceptor: BaseURLRequestAdapter(URL(string:"https://demo3068405.mockable.io")!,
                                                                        [UnauthorizedStatusCodeRequestRetrier()]))
        return sessionManager
    }()
    
    private lazy var storage: AnyDataSource<Data> = {
        // Storage (FileSystem)
        let storage = FileSystemStorageDataSource(fileManager: FileManager.default,
                                                  relativePath: "data",
                                                  writingOptions: .noFileProtection,
                                                  fileNameEncoding: .none)!

        // Storage (UserDefaults)
        // let storage = DeviceStorageDataSource<Data>(UserDefaults.standard, prefix: "ItemEntity")
        
        // Storage (Keychain)
        // let storage = KeychainDataSource<Data>(KeychainService("com.mobilejazz.storage.item"))
        
        // Attaching a logger
        return AnyDataSource(
            DebugDataSource(storage, logger: self.logger)
        )
    }()
    
    lazy var itemComponent: ItemComponent = ItemDefaultModule(executor: self.backgroundExecutor,
                                                              apiClient: self.apiClient,
                                                              storage: self.storage)
}
