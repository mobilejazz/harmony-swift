//
// Copyright 2017 Mobile Jazz SL
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

public enum Action {
    case queue
    case ignore
    case process
}

public struct Filter : OptionSet {
    public let rawValue : Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let never = Filter(rawValue:0)
    public static let applicationBackground = Filter(rawValue:1<<0)
    public static let applicationInactive = Filter(rawValue:1<<1)
    public static let applicationActive = Filter(rawValue:1<<2)
    public static let always = Filter(rawValue:~0)
}

public protocol PushNotificationQueueDelegate : class {
    func actionForNotification(_ userInfo: [AnyHashable : Any], queue: PushNotificationQueue, completionHandler: @escaping (Action, UIBackgroundFetchResult) -> Void )
    func receivedNotification(_ userInfo: [AnyHashable : Any], applicationState: UIApplicationState, queue: PushNotificationQueue)
}

private class PushNotificationQueueItem {
    let userInfo : [AnyHashable : Any]
    let applicationState : UIApplicationState
    let date : Date = Date()
    init(userInfo: [AnyHashable : Any], applicationState: UIApplicationState) {
        self.userInfo = userInfo
        self.applicationState = applicationState
    }
}

public class PushNotificationQueue {
    
    public var filter : Filter = .never
    public weak var delegate : PushNotificationQueueDelegate?
    private let operationQueue : OperationQueue
    
    public init() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.isSuspended = true
    }
    
    public var enabled : Bool {
        get {
            return !operationQueue.isSuspended
        }
        set {
            operationQueue.isSuspended = !newValue
        }
    }
    
    public func clear() {
        operationQueue.cancelAllOperations()
    }
    
    public func addNotification(_ userInfo: [AnyHashable : Any], completion: @escaping (UIBackgroundFetchResult) -> Void = { _ in }) {
        let item = PushNotificationQueueItem.init(userInfo: userInfo, applicationState: UIApplication.shared.applicationState)
        
        var deliverNotification = false
        switch item.applicationState {
        case .active:
            deliverNotification = filter.contains(.applicationActive)
        case .inactive:
            deliverNotification = filter.contains(.applicationInactive)
        case .background:
            deliverNotification = filter.contains(.applicationBackground)
        }
        
        if deliverNotification {
            if let delegate = delegate {
                delegate.actionForNotification(userInfo, queue: self, completionHandler: { (action, result) in
                    completion(result)
                    self.handleItem(item, action: action)
                })
            } else {
                self.handleItem(item)
            }
        }
    }
    
    private func handleItem(_ item: PushNotificationQueueItem, action: Action = .queue) {
        switch action {
        case .queue:
            operationQueue.addOperation({
                self.processItem(item)
            })
        case .process:
            self.processItem(item)
        case .ignore:
            break;
        }
    }
    
    private func processItem(_ item: PushNotificationQueueItem) {
        if let delegate = delegate {
            DispatchQueue.main.async {
                delegate.receivedNotification(item.userInfo, applicationState: item.applicationState, queue: self)
            }
        }
    }
}
