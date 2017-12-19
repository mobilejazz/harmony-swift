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

typedef NS_ENUM(NSInteger, MJFutureState)
{
	MJFutureStateBlank,
	MJFutureStateWaitingBlock,
	MJFutureStateWaitingValueOrError,
	MJFutureStateSent,
};

extern NSString * _Nonnull const MJFutureValueNotAvailableException;
extern NSString * _Nonnull const MJFutureErrorKey;

@protocol MJFutureObserver;

/**
 * Future promise object.
 **/
@interface MJFuture <T> : NSObject

#pragma mark - Creation

/** ************************************ **
 @name Creating Futures
 ** ************************************ **/

/**
 Creates an empty future

 @return An empty future
 */
+ (MJFuture <T>* _Nonnull)emptyFuture;

/**
 Creates an immediate future passing a value

 @param value The value to set to the future
 @return A future
 */
+ (MJFuture <T>* _Nonnull)immediateFuture:(_Nonnull T)value;

/**
 Creates a future from another future

 @param future The future to set to the future
 @return A future
 */
+ (MJFuture <T>* _Nonnull)futureWithFuture:(MJFuture<T>* _Nonnull )future;

#pragma mark - Future lifecyle

/** ************************************ **
 @name Future Lifecycle & Configuration
 ** ************************************ **/

/**
 The queue on which the completion block will be called. Default is nil.
 @discussion If nil, the static default queue will be used instead.
 */
@property (nonatomic, strong, readwrite) dispatch_queue_t _Nonnull returnQueue;

/**
 Sets the default reutrn queue. Default one is the main queue.
 
 @param queue The default return queue
 **/
+ (void)setDefaultReturnQueue:(dispatch_queue_t _Nonnull)queue DEPRECATED_MSG_ATTRIBUTE("Use -inQueue: or -inMainQueue instead.");

/**
 The state of the future.
 **/
@property (nonatomic, assign, readonly) MJFutureState state;

#pragma mark - Future value management

/** ************************************ **
 @name Setting Values & Errors
 ** ************************************ **/

/**
 Sets the value on the future. If the future is ready, the *then* block will be called

 @param value A not null value
 */
- (void)setValue:(_Nullable T)value;

/**
 Sets an error on the future. If the future is ready, the *then* block will be called

 @param error A not null error object
 */
- (void)setError:(NSError * _Nonnull)error;

/**
 If error, the future sends the error. Otherwise sends the value (even if the value is nil).
 
 @param value The value
 @param error The error
 **/
- (void)setValue:(_Nullable T)value error:(NSError * _Nullable)error;

/**
 * Block called upon value is set.
 **/
@property (nonatomic, strong) void (^ _Nullable onSetBlock)(_Nullable T __strong * _Nonnull, NSError * _Nullable __strong * _Nonnull );

#pragma mark - Future execution

/** ************************************ **
 @name Asynchronous Future Management
 ** ************************************ **/

/**
 * Returns the future in the given queue
 **/
- (MJFuture<T>* _Nonnull)inQueue:(dispatch_queue_t _Nonnull)queue;

/**
 * Returns the future in the main queue
 **/
- (MJFuture<T>* _Nonnull)inMainQueue;

/**
 Completion block executed when the future has value.
 
 @param block The block to be executed, with the object or the error passed as parameter
 */
- (void)then:(void (^ _Nullable )(_Nullable T object, NSError *_Nullable error))block;

/** ************************************ **
 @name Synchronous Future Management
 ** ************************************ **/

/**
 Blocks the current thread until the value is obtained or return the value direclty if it is already availble.
 
 @return The future value.
 @discussion If error, this method returns nil and throws an exception;
 */
- (_Nullable T)value;

/**
 Blocks the current thread until the value is obtained or return the value direclty if it is already availble.
 
 @param error The out error
 @return The future value.
 */
- (_Nullable T)valueWithError:(NSError * _Nullable __strong * _Nullable)error;

#pragma mark - Observer management

/** ************************************ **
 @name Observing a Future
 ** ************************************ **/

/**
 Registers an observer.
 @param observer An observer
 **/
- (void)addObserver:(_Nonnull id <MJFutureObserver>)observer;

/**
 Unregisters an observer.
 @param observer An observer
 **/
- (void)removeObserver:(_Nonnull id <MJFutureObserver>)observer;

@end

/**
 * Observer object.
 * @discussion Observer methods may be called from background threads.
 **/
@protocol MJFutureObserver <NSObject>

@optional

- (void)future:(MJFuture *_Nonnull)future didSetValue:(_Nonnull id)value;
- (void)future:(MJFuture *_Nonnull)future didSetError:(NSError *_Nonnull)error;
- (void)didSendFuture:(MJFuture *_Nonnull)future;

@end


@interface MJFuture<T> (Functional)

- (MJFuture* _Nonnull)map:(id _Nonnull (^_Nonnull)(T _Nonnull value))block;
- (MJFuture *_Nonnull)mapError:(NSError*  _Nonnull (^_Nonnull)(NSError* _Nonnull error))block;
- (MJFuture *_Nonnull)flatMap:(MJFuture* _Nonnull (^_Nonnull)(id _Nonnull value))block;
- (MJFuture *_Nonnull)recover:(MJFuture*  _Nonnull (^_Nonnull)(NSError*_Nonnull error))block;
- (MJFuture *_Nonnull)filter:(NSError*  _Nonnull (^_Nonnull)(id _Nonnull value))block;

@end
