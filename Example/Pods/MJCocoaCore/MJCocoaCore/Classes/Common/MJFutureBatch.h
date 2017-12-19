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

#import <Foundation/Foundation.h>
#import "MJFuture.h"

/**
 * Batch management of futures.
 **/
@interface MJFutureBatch <T> : NSObject

/**
 * Returns an empty future batch.
 **/
+ (MJFutureBatch <T> * _Nonnull)emptyBatch;

/**
 * Batches a future.
 * @param future A future to batch.
 **/
- (void)batchFuture:(MJFuture <T> * _Nonnull)future;

/**
 * Batches a future.
 * @param future A future to batch.
 * @param context A context object.
 **/
- (void)batchFuture:(MJFuture <T> * _Nonnull)future context:(id _Nullable)context;

/**
 * Sets the "then" block. This block will be called for each future.
 * @return The self instance.
 **/
- (MJFutureBatch <T> * _Nonnull)then:(void (^ _Nonnull)(_Nullable T object, NSError *_Nullable error, id _Nullable context))block;

/**
 * A completion block that will be called after all futures end.
 **/
- (void)completion:(void (^_Nonnull)(NSError * _Nullable error, id _Nullable context))completion;

@end
