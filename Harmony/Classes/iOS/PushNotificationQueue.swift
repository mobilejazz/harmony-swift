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

/// The delegate object
public protocol PushNotificationQueueDelegate : class {
    
    /// Action for a new incoming push notification.
    ///
    /// - Parameters:
    ///   - userInfo: The push notification
    ///   - queue: The queue.
    ///   - completionHandler: The completion handler. This closure must be called.
    func actionForNotification(_ userInfo: [AnyHashable : Any], queue: PushNotificationQueue, completionHandler: @escaping (PushNotificationQueue.Action, UIBackgroundFetchResult) -> Void )
    
    /// Main push notification delivery method.
    ///
    /// - Parameters:
    ///   - userInfo: The push notification
    ///   - applicationState: The application state when the push notification was received.
    ///   - queue: The notification queue.
    func receivedNotification(_ userInfo: [AnyHashable : Any], applicationState: UIApplication.State, queue: PushNotificationQueue)
}

private class PushNotificationQueueItem {
    let userInfo : [AnyHashable : Any]
    let applicationState : UIApplication.State
    let date : Date = Date()
    init(userInfo: [AnyHashable : Any], applicationState: UIApplication.State) {
        self.userInfo = userInfo
        self.applicationState = applicationState
    }
}

///
/// Class responsible of processing incoming push notifications and deliver them to its delegate in the appropiated time.
///
public class PushNotificationQueue {
    
    /// Filter options.
    public struct Filter : OptionSet {
        public let rawValue : Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// Never filter. Deliver all incoming notifications.
        public static let never = Filter(rawValue:0)
        /// Filter notifications received in the background. Deliver otherwise.
        public static let applicationBackground = Filter(rawValue:1<<0)
        /// Filter notifications received when inactive. Deliver otherwise.
        public static let applicationInactive = Filter(rawValue:1<<1)
        /// Filter notifications received when active. Deliver otherwise.
        public static let applicationActive = Filter(rawValue:1<<2)
        /// Filter all notifications. Deliver nothing.
        public static let always = Filter(rawValue:~0)
    }
    
    /// Puch notification action
    ///
    /// - queue: Add to the queue.
    /// - ignore: Ignore notification.
    /// - process: Process right away, ignoring the queue.
    public enum Action {
        case queue
        case ignore
        case process
    }
    
    /// Filter option. Default value is .never.
    public var filter : Filter = .never
    /// The delegate object.
    public weak var delegate : PushNotificationQueueDelegate?
    
    private let operationQueue : OperationQueue
    
    /// Main initializer
    public init() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.isSuspended = true
    }
    
    /// Enables or disables the notification delivery.
    public var enabled : Bool {
        get {
            return !operationQueue.isSuspended
        }
        set {
            operationQueue.isSuspended = !newValue
        }
    }
    
    /// Removes all pending to be delivered notifications.
    public func clear() {
        operationQueue.cancelAllOperations()
    }
    
    /// Adds a new notification into the queue.
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
        @unknown default:
            print("Not processing push notification because application state \(item.applicationState) is not supported.")
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
