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

#import "MJFuture.h"
#import "MJExecutor.h"

/**
 * Interactor superclass.
 **/
@interface MJInteractor : NSObject

/**
 * Default initializer.
 *
 * @discussion Use -init method to use a default executor per interactor class.
 **/
- (instancetype)initWithExecutor:(MJExecutor*)executor;

/**
 * The executor.
 **/
@property (nonatomic, strong) MJExecutor *executor;

/**
 * Executes a block in a background queue. Locks the interactor thread.
 * @discussion A `begin` call must be in corresponded to a `end` call.
 **/
- (void)begin:(void (^)(void))block __attribute__((deprecated("Use -[self.executor submit:] instead")));

/**
 * Executes a block in the main queue. Unlocks the interactor thread.
 * @discussion A `begin` call must be in corresponded to a `end` call.
 **/
- (void)end:(void (^)(void))block __attribute__((deprecated("Use -[self.executor submit:] instead")));

/**
 * Unlock the interactor thread. This is equal to calling end with a nil block parameter.
 */
- (void)end __attribute__((deprecated("Use -[self.executor submit:] instead")));

/**
 * Locks the interactor thread, executes the block in a background queue and then unlocks the interactor thread.
 * @discussion When using this method, do not use neither `-begin:` nor `-end:` or `-end` methods.
 **/
- (void)perform:(void (^)(void))block __attribute__((unavailable("This method is unavailable. Use -[self.executor submit:] instead")));

/**
 * Creates a future to be used, and does the thread management.
 * @discussion When using this method, do not use neither `-begin:` nor `-end:` or `-end` methods.
 **/
- (MJFuture*)performWithFuture:(void (^)(MJFuture *future))block __attribute__((deprecated("Use -[self.executor ft_submit:] instead")));

/**
 * YES if executing, NO otherwise. This property is KVO compliant.
 **/
@property (nonatomic, assign, readonly) BOOL isExecuting __attribute__((deprecated("Use self.executor.isExeucting instead")));

/**
 * Set needs refresh method. This will flag the `refresh` property to YES until the end of the interactor.
 **/
- (void)setNeedsRefresh;

/**
 * A refresh flag.
 **/
@property (nonatomic, assign, readonly) BOOL refresh;

@end

