//
// Copyright 2022 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import Harmony
import HarmonyTesting
import Nimble
import XCTest

class CacheRepositoryTests: XCTestCase {
    private var main: InMemoryDataSource<Int>!
    private var cache: InMemoryDataSource<Int>!

    private typealias DataSourceSpyType = DataSourceSpy<InMemoryDataSource<Int>, Int>

    private var mainSpy: DataSourceSpyType!
    private var cacheSpy: DataSourceSpyType!

    private var cacheRepository: CacheRepository<DataSourceSpyType, DataSourceSpyType, Int>!

    private func setup(
        mainData mainKeyValue: (query: KeyQuery, value: Int)?,
        cacheData cacheKeyValue: (query: KeyQuery, value: Int)?,
        objectValid: Bool = true
    ) throws {
        main = InMemoryDataSource()
        cache = InMemoryDataSource()

        mainSpy = DataSourceSpy(main)
        cacheSpy = DataSourceSpy(cache)

        cacheRepository = CacheRepository(
            main: mainSpy,
            cache: cacheSpy,
            validator: MockObjectValidation<Int>(objectValid: objectValid, arrayValid: true)
        )

        if let mainKeyValue = mainKeyValue {
            _ = try main.put(mainKeyValue.value, in: mainKeyValue.query).result.get()
        }

        if let cacheKeyValue = cacheKeyValue {
            _ = try cache.put(cacheKeyValue.value, in: cacheKeyValue.query).result.get()
        }
    }

    func test_getValue_withMain_withEmptyMain() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        try setup(mainData: nil, cacheData: nil)
        let operation = MainOperation()

        expect {
            // When
            try self.cacheRepository.get(query, operation: operation).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.NotFound.self))
        expect(self.cacheSpy.getCalls.count).to(equal(0))
        expect(self.mainSpy.getCalls.count).to(equal(1))
        expect(self.mainSpy.getCalls[0] as! IdQuery<String>).to(be(query))
    }

    func test_getValue_withMain_withMainValue() throws {
        // Given
        let value = Int.random()
        let query = IdQuery(String(randomOfLength: 8))
        try setup(mainData: (query, value), cacheData: nil)
        let operation = MainOperation()

        // When
        let result = try cacheRepository.get(query, operation: operation).result.get()

        // Then
        expect(result).to(equal(value))
        expect(self.cacheSpy.getCalls.count).to(equal(0))
        expect(self.mainSpy.getCalls.count).to(equal(1))
        expect(self.mainSpy.getCalls[0] as! IdQuery<String>).to(be(query))
    }

    func test_getValue_withCache_withEmptyCache() throws {
        // Given
        let query = IdQuery(String(randomOfLength: 8))
        try setup(mainData: nil, cacheData: nil)
        let operation = CacheOperation()

        expect {
            // When
            try self.cacheRepository.get(query, operation: operation).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.NotFound.self))
        expect(self.mainSpy.getCalls.count).to(equal(0))
        expect(self.cacheSpy.getCalls.count).to(equal(1))
        expect(self.cacheSpy.getCalls[0] as! IdQuery<String>).to(be(query))
    }

    func test_getValue_withCache_withCacheValue() throws {
        // Given
        let value = Int.random()
        let query = IdQuery(String(randomOfLength: 8))
        try setup(mainData: nil, cacheData: (query, value))
        let operation = CacheOperation()

        // When
        let result = try cacheRepository.get(query, operation: operation).result.get()

        // Then
        expect(result).to(equal(value))
        expect(self.mainSpy.getCalls.count).to(equal(0))
        expect(self.cacheSpy.getCalls.count).to(equal(1))
        expect(self.cacheSpy.getCalls[0] as! IdQuery<String>).to(be(query))
    }

    func test_getValue_withCacheSync_withEmptyCache_withMainValue() throws {
        // Given
        let value = Int.random()
        let query = IdQuery(String(randomOfLength: 8))
        try setup(mainData: (query, value), cacheData: nil)
        let operation = CacheSyncOperation()

        // When
        let result = try cacheRepository.get(query, operation: operation).result.get()

        // Then
        expect(result).to(equal(value))
        expect(self.mainSpy.getCalls.count).to(equal(1))
        expect(self.mainSpy.getCalls[0] as! IdQuery<String>).to(be(query))
        expect(self.cacheSpy.putCalls.count).to(equal(1))
        expect(self.cacheSpy.putCalls[0].value).to(equal(value))
        expect(self.cacheSpy.putCalls[0].query as! IdQuery<String>).to(be(query))
    }

    func test_getValue_withCacheSync_withValidCacheValue() throws {
        // Given
        let value = Int.random()
        let query = IdQuery(String(randomOfLength: 8))
        try setup(mainData: nil, cacheData: (query, value))
        let operation = CacheSyncOperation()

        // When
        let result = try cacheRepository.get(query, operation: operation).result.get()

        // Then
        expect(result).to(equal(value))
        expect(self.mainSpy.getCalls.count).to(equal(0))
        expect(self.cacheSpy.getCalls.count).to(equal(1))
        expect(self.cacheSpy.getCalls[0] as! IdQuery<String>).to(be(query))
    }

    func test_getValue_withCacheSync_withInvalidCacheValue_withMainValue() throws {
        // Given
        let validValue = Int.random()
        let invalidValue = Int.random()
        let query = IdQuery(String(randomOfLength: 8))
        try setup(mainData: (query, validValue), cacheData: (query, invalidValue), objectValid: false)
        let operation = CacheSyncOperation()

        // When
        let result = try cacheRepository.get(query, operation: operation).result.get()

        // Then
        expect(result).to(equal(validValue))
        expect(self.mainSpy.getCalls.count).to(equal(1))
        expect(self.mainSpy.getCalls[0] as! IdQuery<String>).to(be(query))
        expect(self.cacheSpy.getCalls.count).to(equal(1))
        expect(self.cacheSpy.getCalls[0] as! IdQuery<String>).to(be(query))
        expect(self.cacheSpy.putCalls.count).to(equal(1))
        expect(self.cacheSpy.putCalls[0].value).to(equal(validValue))
        expect(self.cacheSpy.putCalls[0].query as! IdQuery<String>).to(be(query))
    }

    func test_getValue_withCacheSync_withInvalidCacheValue_withEmptyMain() throws {
        // Given
        let invalidValue = Int.random()
        let query = IdQuery(String(randomOfLength: 8))
        try setup(mainData: nil, cacheData: (query, invalidValue), objectValid: false)
        let operation = CacheSyncOperation()

        expect {
            // When
            try self.cacheRepository.get(query, operation: operation).result.get()
        }
        // Then
        .to(throwError(errorType: CoreError.NotFound.self))
        expect(self.mainSpy.getCalls.count).to(equal(1))
        expect(self.mainSpy.getCalls[0] as! IdQuery<String>).to(be(query))
        expect(self.cacheSpy.getCalls.count).to(equal(1))
        expect(self.cacheSpy.getCalls[0] as! IdQuery<String>).to(be(query))
    }
}
