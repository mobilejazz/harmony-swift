//
// Copyright 2018 Mobile Jazz SL
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

/// Custom validation errors
public enum ValidationError : Error {
    // Validation is not valid
    case notValid
}

/// Object validation interface
public protocol ObjectValidation {
    /// Validates an object
    func isObjectValid<T>(_ object: T) -> Bool
    
    /// Validates an array of objects
    func isArrayValid<T>(_ objects: [T]) -> Bool
}

public extension ObjectValidation {
    
    /// Validator method for arrays
    ///
    /// The validation process iterates over the array and is considered valid if all objects are valid.
    /// Note that:
    ///   - An empty array is considered invalid
    ///   - A nil instance is considered invalid
    ///
    /// - Parameter object: The object to validate.
    /// - Returns: true if valid, false otherwise.
    public func isArrayValid<T>(_ objects: [T]) -> Bool {
        if objects.isEmpty {
            return false
        }
        for object in objects {
            if !isObjectValid(object) {
                return false
            }
        }
        return true
    }
}

///
/// Performs validation on the contained repository.
/// Note that validation only occur in the get and getAll methods.
/// If not valid, the returned future is resolved with a ValidationError.notValid error
///
public class DataSourceValidator<T>: DataSource<T> {
    
    private let dataSource : DataSource<T>
    private let validator: ObjectValidation
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - dataSource: The contained repository
    ///   - validation: The storage validation
    public init(dataSource: DataSource<T>, validator: ObjectValidation) {
        self.dataSource = dataSource
        self.validator = validator
    }
    
    public override func get(_ query: Query) -> Future<T?> {
        return dataSource.get(query).filter { value in
            if !self.validator.isObjectValid(value) {
                throw ValidationError.notValid
            }
        }
    }
    
    public override func getAll(_ query: Query) -> Future<[T]> {
        return dataSource.getAll(query).filter { values in
            if !self.validator.isArrayValid(values) {
                throw ValidationError.notValid
            }
        }
    }
    
    @discardableResult
    public override func put(_ value: T?, in query: Query) -> Future<T> {
        return dataSource.put(value, in: query)
    }
    
    @discardableResult
    public override func putAll(_ array: [T], in query: Query) -> Future<[T]> {
        return dataSource.putAll(array, in: query)
    }
    
    @discardableResult
    public override func delete(_ query: Query) -> Future<Void> {
        return dataSource.delete(query)
    }
    
    @discardableResult
    public override func deleteAll(_ query: Query) -> Future<Void> {
        return dataSource.deleteAll(query)
    }
}
