//
//  ItemProvider.swift
//  Harmony_Example
//
//  Created by Joan Martin on 22/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Harmony
import Alamofire

protocol ItemComponent {
    func itemListPresenter(view: ItemListPresenterView) -> ItemListPresenter
}

class ItemDefaultModule: ItemComponent {
    private let executor: Executor
    private let storage: AnyDataSource<Data>
    
    init(executor: Executor, apiClient: Session, storage: AnyDataSource<Data>) {
        self.executor = executor
        self.storage = storage
    }
    
    private lazy var networkDataSource: AnyDataSource<ItemEntity> = {
        let baseDataSource = GetNetworkDataSource<ItemEntity>(url: "https://demo3068405.mockable.io/")
        
        // To debug the UI upon random API behavior, adding this intermediate layer
        let itemNetworkDataSource = DebugDataSource(DataSourceAssembler(get: baseDataSource),
                                                    delay: .sync(0.5),
                                                    error: .error(CoreError.Failed("Debug Fail"), probability: 0.01),
                                                    logger: DeviceConsoleLogger())
        
        // Adding retry behavior in case of error
        let networkDataSource = RetryDataSource(itemNetworkDataSource, retryCount: 1) { error in
            return error._code == NSURLErrorTimedOut && error._domain == NSURLErrorDomain
        }
        return AnyDataSource(networkDataSource)
    }()
    
    private lazy var storageDataSource: AnyDataSource<ItemEntity> = {
        return AnyDataSource(
            DataSourceMapper(dataSource: self.storage,
                             toInMapper: EncodableToDataMapper<ItemEntity>(),
                             toOutMapper: DataToDecodableMapper<ItemEntity>())
        )
    }()
    
    private lazy var repository: AnyRepository<Item> = {
        
        let vastra = VastraService([VastraTimestampStrategy()])
        let storageValidationDataSource = DataSourceValidator(dataSource: self.storageDataSource,
                                                              validator: vastra)
        
        let cacheRepo = CacheRepository(main: self.networkDataSource,
                                        cache: storageValidationDataSource)
        return AnyRepository(
            RepositoryMapper(repository: cacheRepo,
                                toInMapper: EncodableToDecodableMapper<Item, ItemEntity>(),
                                toOutMapper: EncodableToDecodableMapper<ItemEntity, Item>())
        )
    }()
    
    private func getAllItemsInteractor() -> GetAllItemsInteractor {
        return GetAllItemsInteractor(executor: self.executor,
                                     getItems: Interactor.GetAllByQuery(DirectExecutor(), self.repository))
    }
    
    func itemListPresenter(view: ItemListPresenterView) -> ItemListPresenter {
        return ItemListDefaultPresenter(view, self.getAllItemsInteractor())
    }
}
