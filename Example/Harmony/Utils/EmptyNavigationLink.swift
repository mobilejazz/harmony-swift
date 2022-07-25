//
// Copyright 2022 Zemantics OÜ
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

import SwiftUI

public struct EmptyNavigationLink<Destination: View>: View {
    private let lazyDestination: LazyView<Destination>
    private let isActive: Binding<Bool>
    
    public init<T>(
        @ViewBuilder destination: @escaping (T) -> Destination,
        selection: Binding<T?>
    )  {
        lazyDestination = LazyView(destination(selection.wrappedValue!))
        isActive = .init(
            get: { selection.wrappedValue != nil },
            set: { isActive in
                if !isActive {
                    selection.wrappedValue = nil
                }
            }
        )
    }
    
    public var body: some View {
        NavigationLink(
            destination: lazyDestination,
            isActive: isActive,
            label: { EmptyView() }
        )
    }
}
