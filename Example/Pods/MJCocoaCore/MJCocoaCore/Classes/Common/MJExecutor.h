//
// Copyright 2015 Mobile Jazz SL
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

#import <Foundation/Foundation.h>

/**
 Executor
 */
@interface MJExecutor : NSObject

/**
 Default initializer.
 
 @param queue The queue to be used, or nil to not use any queue and execute the code directly.
 @return The initialized instance
 */
- (instancetype _Nonnull)initWithQueue:(dispatch_queue_t _Nullable)queue;

/**
 YES if executing, NO otherwise
 */
@property (nonatomic, assign, readonly, getter=isExecuting) BOOL executing;

/**
 Submits a new block for execution
 
 @param block The block to be executed. Contains as a parameter another block to be called after the execution ends.
 @discussion The block end must be called once after the operation ends, otherwise the executor's queue won't be unlocked.
 */
- (void)submit:(void (^_Nonnull)(void (^_Nonnull end)(void)))block;

@end

#import "MJFuture.h"

/**
 Extension for MJFuture support
 */
@interface MJExecutor (MJFuture)

/**
 Customized submit method for MJFuture support
 
 @param block The block to be executed. Contains as a parameter a future to be filled.
 @return A future for the result of the execution.
 @discussion The returned future executes by default on the main thread.
 */
- (MJFuture * _Nonnull)ft_submit:(void (^_Nonnull)(MJFuture * _Nonnull future))block;

@end

