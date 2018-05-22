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

/// The binary search type
///
/// - equal: Finds the same value
/// - smallerOrEqual: Finds the closest index of the array which is smaller or equal to the target value
/// - greaterOrEqual: Finds the closest index of the array which is greater or equal to the target value
public enum BinarySearchType {
    case equal
    case smallerOrEqual
    case greaterOrEqual
}

extension Array where Element : Comparable {
    
    /// Performs a binary search to find for the target value. The array must be sorted ascending, otherwise unexpected behavior might raise.
    ///
    /// - Parameters:
    ///   - target: The target value to find
    ///   - type: The binary search type. Use equal to find the specific value. Use smallerOrEqual or greaterOrEqual to find the closest value.
    /// - Returns: The index of the array
    /// - Throws: This method may throw a CoreError.NotFound error if not found, or a CoreError.IllegalArgument if the array used is empty.
    public func binarySearch(_ target: Element, type:  BinarySearchType = .equal) throws -> Int {
        if count == 0 {
            throw CoreError.IllegalArgument("Cannot perform a binary search on an empty array.")
        }
        
        if count == 1 {
            switch type {
            case .equal:
                if target == first! {
                    return 0
                }
            case .smallerOrEqual:
                if target <= first! {
                    return 0
                }
                
            case .greaterOrEqual:
                if target >= first! {
                    return 0
                }
            }
            // Otheriwse, not found
            throw CoreError.NotFound()
        }
        
        var highIndex = count - 1
        var lowIndex = 0
        
        switch type {
        case .smallerOrEqual:
            if target <= first! {
                return lowIndex
            } else if target > last! {
                throw CoreError.NotFound()
            }
        case .greaterOrEqual:
            if target < first! {
                throw CoreError.NotFound()
            } else if target >= last! {
                return highIndex
            }
        case .equal:
            if target < first! || target > last! {
                throw CoreError.NotFound()
            }
        }
        
        while highIndex > lowIndex {
            let index = (highIndex + lowIndex) / 2
            let value = self[index]
            
            if self[lowIndex] == target {
                return lowIndex
            } else if value == target {
                return index
            } else if self[highIndex] == target {
                return highIndex
            } else if value > target {
                if highIndex == index {
                    switch type {
                    case .smallerOrEqual:
                        return Swift.min(highIndex, lowIndex)
                    case .greaterOrEqual:
                        return Swift.max(highIndex, lowIndex)
                    case .equal:
                        throw CoreError.NotFound()
                    }
                }
                highIndex = index
            } else {
                if lowIndex == index {
                    switch type {
                    case .smallerOrEqual:
                        return Swift.min(highIndex, lowIndex)
                    case .greaterOrEqual:
                        return Swift.max(highIndex, lowIndex)
                    case .equal:
                        throw CoreError.NotFound()
                    }
                }
                lowIndex = index
            }
        }
        
        switch type {
        case .smallerOrEqual:
            return Swift.min(highIndex, lowIndex)
        case .greaterOrEqual:
            return Swift.max(highIndex, lowIndex)
        case .equal:
            throw CoreError.NotFound()
        }
    }
    
    /// Performs a binary search to find for the target value. The array must be sorted ascending, otherwise unexpected behavior might raise.
    ///
    /// - Parameters:
    ///   - target: The target value to find
    ///   - type: The binary search type. Use equal to find the specific value. Use smallerOrEqual or greaterOrEqual to find the closest value.
    /// - Returns: A future containing the index of the array or an error (either a CoreError.NotFound error if not found, or a CoreError.IllegalArgument if the array used is empty)
    public func binarySearch(_ target: Element, type:  BinarySearchType = .equal) -> Future<Int> {
        return Future() { resolver in
            let index : Int = try binarySearch(target, type: type)
            resolver.set(index)
        }
    }
}
