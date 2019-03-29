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
import UIKit

/// A protocol defining a var to fetch the cell identifier.
/// Default implementation returns the cell type name as the identifier
public protocol UITableViewCellIdentifier {
    /// The identifier of the cell
    static var identifier : String { get }
}

extension UITableViewCell : UITableViewCellIdentifier {
    public static var identifier: String {
        return String(describing: self)
    }
}

public extension UITableView {
    /// Dequeues a reusable cell given a cell type. The identifier of the cell is defined by the UITableViewCellIdentifier protocol.
    ///
    /// - Parameters:
    ///   - type: The type of the cell
    ///   - indexPath: The index path
    /// - Returns: The dequeued cell
    func dequeueReusableCell<T>(_ type: T.Type, for indexPath: IndexPath) -> T where T:UITableViewCell {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
}
