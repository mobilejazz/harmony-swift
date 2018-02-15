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

#import <Foundation/Foundation.h>

@class MJFuture<T>;

typedef NS_ENUM(NSUInteger, MJFutureMemoryReferenceType)
{
    MJFutureMemoryReferenceTypeStrong,
    MJFutureMemoryReferenceTypeWeak
};

/**
 A future hub acts as a cloner of a given future. It generates new futures that react to the original one.
 Typically used for reactive futures to maintain a live pipeline stream.
 */
@interface MJFutureHub <T> : NSObject

/**
 Static initializer

 @return An empty hub.
 */
+ (MJFutureHub <T> * _Nonnull)hub;

/**
 Static initializer.

 @param future The future for the hub
 @return A new hub instance.
 */
+ (MJFutureHub <T> * _Nonnull)hubWithFuture:(MJFuture <T> * _Nonnull)future;

/**
 * Default initializer

 @param future The future to use as base future
 @return A new initialized instance
 */
- (instancetype _Nonnull)initWithFuture:(MJFuture<T> *_Nullable)future;

/**
 @property The future beign observed.
 */
@property (nonatomic, strong, readwrite) MJFuture<T> * _Nullable future;

/**
 Creates a new future and plugs it to the hub (with a weak memory reference).
 
 @return A new future
 */
- (MJFuture<T>* _Nonnull)plug;

/**
 Creates a new future and plugs it to the hub.
 
 @param type The memory reference type.
 @return A new future
 */
- (MJFuture<T>* _Nonnull)plugAs:(MJFutureMemoryReferenceType)type;

/**
 Plugs (subscries) the given future (keepign a week memory reference).
 
 @param future The future to plug.
 */
- (void)plug:(MJFuture<T> * _Nonnull)future;

/**
 Plugs (subscries) the given future to the hub.
 
 @param future The future to plug.
 @param type The memory reference type
 */
- (void)plug:(MJFuture<T> * _Nonnull)future as:(MJFutureMemoryReferenceType)type;

/**
 Unplugs (unsubscribes) a future.
 
 @param future The future to unplug
 */
- (void)unplug:(MJFuture<T>* _Nonnull)future;

/**
 Unplugs (unsubscribes) all futures.
 */
- (void)unplugAll;

@end
