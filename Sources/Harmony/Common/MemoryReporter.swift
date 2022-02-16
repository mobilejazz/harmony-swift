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
import MachO


/// A description of the usage of the RAM memory
public struct RamState: CustomStringConvertible {
    
    let total: UInt64 // In bytes
    let free: UInt64  // In bytes
    let used: UInt64  // In bytes

    public var description: String {
        let usedInMB = used / 1024 / 1024
        let freeInMB = free / 1024 / 1024
        let totalInMB = total / 1024 / 1024

        return "RAM: used: \(usedInMB)MB free: \(freeInMB)MB total: \(totalInMB)MB"
    }
}

/// A utility that provides information about a system's memory
public protocol MemoryReporter {
    func ram() -> RamState?
}

/// A concrete implementation of Memory reporter that retrieves the current usage of the RAM memory in the current device.
public struct DeviceMemoryReporter: MemoryReporter {
    
    public init() {}
    
    public func ram() -> RamState? {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        let totalMB = ProcessInfo.processInfo.physicalMemory
        guard result == KERN_SUCCESS else {
            return nil
        }
        let usedMB = taskInfo.phys_footprint
        let freeMB = totalMB - usedMB
        return RamState(total: totalMB, free: freeMB, used: usedMB)
    }
}
