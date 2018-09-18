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
#import "MJFutureResult.h"

@class MJFutureHub<T>;

typedef NS_ENUM(NSInteger, MJFutureState)
{
    MJFutureStateBlank,
    MJFutureStateWaitingBlock,
    MJFutureStateWaitingValueOrError,
    MJFutureStateSent,
};

extern NSString * _Nonnull const MJFutureValueNotAvailableException;
extern NSString * _Nonnull const MJFutureErrorKey;

NS_SWIFT_UNAVAILABLE("")
@protocol MJFutureObserver;

/**
 * Future promise object.
 **/
//NS_SWIFT_NAME(Future) // <- keeping the MJ prefix as a way to differenciate it from the pure swift Futures of MJSwiftCore
@interface MJFuture <T> : NSObject

#pragma mark - Creation

/** ************************************ **
 @name Creating Futures
 ** ************************************ **/

/**
 Creates an empty future
 
 @return An empty future
 */
+ (MJFuture <T>* _Nonnull)emptyFuture NS_SWIFT_UNAVAILABLE("");

/**
 Creates an empty reactive future.
 
 @return An empty reactive future.
 **/
+ (MJFuture <T>* _Nonnull)reactiveFuture NS_SWIFT_UNAVAILABLE("");

/**
 Creates an immediate future passing a value
 
 @param value The value to set to the future
 @return A future
 */
+ (MJFuture <T>* _Nonnull)immediateFuture:(_Nullable T)value NS_SWIFT_UNAVAILABLE("");

/**
 Creates an immediate future with an error.
 
 @param error The error
 @return A future
 **/
+ (MJFuture <T>* _Nonnull)futureWithError:(NSError * _Nonnull)error NS_SWIFT_UNAVAILABLE("");

/**
 Creates a future from another future
 
 @param future The future to set to the future
 @return A future
 */
+ (MJFuture <T>* _Nonnull)futureWithFuture:(MJFuture<T>* _Nonnull)future NS_SWIFT_UNAVAILABLE("");

/**
 Creates an empty future
 @param reactive YES for a reactive future, NO otherwise
 @return The initialized instance
 **/
- (_Nonnull instancetype)initReactive:(BOOL)reactive;

/**
 Creates a future from a future
 @param future The future
 @return The initialized instance
 **/
- (_Nonnull instancetype)initWithFuture:(MJFuture<T>* _Nonnull)future NS_SWIFT_NAME(init(_:));

/**
 Creates an immediate future passing a value
 
 @param value The value to set to the future
 @return A future
 */
- (_Nonnull instancetype)initWithValue:(_Nullable T)value NS_SWIFT_NAME(init(_:));

/**
 Creates an immediate future passing a value
 
 @param value The value to set to the future
 @param reactive YES for a reactive future, NO otherwise
 @return A future
 */
- (_Nonnull instancetype)initWithValue:(_Nullable T)value reactive:(BOOL)reactive NS_SWIFT_NAME(init(_:reactive:));

/**
 Creates an immediate future with an error.
 
 @param error The error
 @return A future
 */
- (_Nonnull instancetype)initWithError:(NSError * _Nonnull)error NS_SWIFT_NAME(init(_:));

/**
 Creates an immediate future with an error.
 
 @param error The error
 @param reactive YES for a reactive future, NO otherwise
 @return A future
 */
- (_Nonnull instancetype)initWithError:(NSError * _Nonnull)error reactive:(BOOL)reactive NS_SWIFT_NAME(init(_:reactive:));


#pragma mark - Future lifecyle

/** ************************************ **
 @name Future Lifecycle & Configuration
 ** ************************************ **/

/**
 Property indicating if the future is reactive. YES if reactive, NO otherwise.
 @discussion A reactive future might be called its completion block more than once.
 **/
@property (nonatomic, assign, readonly) BOOL reactive;

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
 Configures the receiver with the same reactiveness as the given future.
 
 @param future The future to mimic its reactiveness.
 */
- (void)mimic:(MJFuture<T>* _Nonnull)future NS_SWIFT_UNAVAILABLE("");

/**
 Sets the value on the future. If the future is ready, the *then* block will be called
 
 @param value A not null value
 */
- (void)setValue:(_Nullable T)value NS_SWIFT_NAME(set(_:));

/**
 Sets an error on the future. If the future is ready, the *then* block will be called
 
 @param error A not null error object
 */
- (void)setError:(NSError * _Nonnull)error NS_SWIFT_NAME(set(_:));

/**
 If error, the future sends the error. Otherwise sends the value (even if the value is nil).
 
 @param value The value
 @param error The error
 **/
- (void)setValue:(_Nullable T)value error:(NSError * _Nullable)error NS_SWIFT_NAME(set(value:error:));

/**
 Sets the future with the result of another future.
 
 @param future The future to set the current future
 **/
- (void)setFuture:(MJFuture * _Nonnull)future NS_SWIFT_NAME(set(_:));

/**
 * Block called upon value is set.
 *
 * @param block The block called.
 **/
- (void)didSet:(void (^_Nonnull)(void))block NS_SWIFT_NAME(onSet(_:));

/**
 * Block called upon value is set.
 *
 * @param block The block called.
 * @discussion The block parameters are pointers to the value/error. These pointers can be changed in order to replace the setted value or error.
 **/
- (void)onSet:(void (^_Nonnull)(_Nullable T __strong * _Nonnull, NSError * _Nullable __strong * _Nonnull ))block;

#pragma mark - Future execution

/** ************************************ **
 @name Asynchronous Future Management
 ** ************************************ **/

/**
 * Returns the future in the given queue. Default queue is nil.
 * @discussion A nil queue will execute the then block in the same queue where the setValue/setError happens.
 **/
- (MJFuture<T>* _Nonnull)inQueue:(dispatch_queue_t _Nullable)queue NS_SWIFT_NAME(on(_:));

/**
 * Returns the future in the main queue
 **/
- (MJFuture<T>* _Nonnull)inMainQueue NS_SWIFT_NAME(onMainQueue());

/**
 Completion block executed when the future has value.
 
 @param block The block to be executed, with the object or the error passed as parameter
 */
- (void)then:(void (^ _Nonnull)(_Nullable T value, NSError *_Nullable error))block NS_SWIFT_UNAVAILABLE("");

/**
 * Success block. Returns a new future instance chained to the original one.
 **/
- (MJFuture<T>* _Nonnull)success:(void (^ _Nonnull)(_Nullable T value))success NS_SWIFT_NAME(then(_:));

/**
 * Failure block. Returns a new future instance chained to the original one.
 **/
- (MJFuture<T>* _Nonnull)failure:( void (^ _Nonnull)(NSError * _Nonnull error))failure NS_SWIFT_NAME(fail(_:));

/**
 Completes the future (if not completed yet). Completed futures cannot be used anymore and no then block will be called afterwards.
 
 @discussion Futures might be completed to finish the expectation of a value and then block. When completed, all then blocks and values are released.
 **/
- (void)complete;

/** ************************************ **
 @name Synchronous Future Management
 ** ************************************ **/

/**
 Blocks the current thread until the value is obtained or return the value direclty if it is already availble.
 
 @return The future value.
 @discussion If error, this method returns nil and throws an exception, containing the error inside the userInfo for the key MJFutureErrorKey.
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
- (void)addObserver:(_Nonnull id <MJFutureObserver>)observer NS_SWIFT_UNAVAILABLE("");

/**
 Unregisters an observer.
 @param observer An observer
 **/
- (void)removeObserver:(_Nonnull id <MJFutureObserver>)observer NS_SWIFT_UNAVAILABLE("");

/**
 Returns a hub associated to the current future
 */
@property (nonatomic, strong, readwrite) MJFutureHub<T> * _Nonnull hub;

@end

/**
 * Observer object.
 * @discussion Observer methods may be called from background threads.
 **/
NS_SWIFT_UNAVAILABLE("")
@protocol MJFutureObserver <NSObject>

@optional

- (void)future:(MJFuture *_Nonnull)future didSetValue:(_Nonnull id)value;
- (void)future:(MJFuture *_Nonnull)future didSetError:(NSError *_Nonnull)error;
- (void)didSendFuture:(MJFuture *_Nonnull)future;

@end


@interface MJFuture<T> (Functional)

/**
 Mappes the value and return a new future with the value mapped.
 **/
- (MJFuture * _Nonnull)map:(id _Nonnull (^_Nonnull)(T _Nonnull value))block;

/**
 Mappes the error and return a new future with the error mapped.
 **/
- (MJFuture <T> *_Nonnull)mapError:(NSError * _Nonnull (^_Nonnull)(NSError * _Nonnull error))block;

/**
 Intercepts the value if success and returns a new future of a mapped type to be chained
 **/
- (MJFuture *_Nonnull)flatMap:(MJFuture * _Nonnull (^_Nonnull)(id _Nonnull value))block;

/**
 Intercepts the error (if available) and returns a new future of type T.
 **/
- (MJFuture <T> *_Nonnull)recover:(MJFuture <T> * _Nonnull (^_Nonnull)(NSError * _Nonnull error))block;

/**
 Filters the value and allows to exchange it for an error.
 **/
- (MJFuture <T> *_Nonnull)filter:(NSError * _Nonnull (^_Nonnull)(id _Nonnull value))block;

/**
 On completion block.
 **/
- (MJFuture <T> *_Nonnull)onCompletion:(void  (^_Nonnull)(void))block;

/**
 Intercepts a future then block and exposes it, returning a new chained future.
 **/
- (MJFuture <T> *_Nonnull)andThen:(void (^ _Nonnull)(_Nullable T value, NSError *_Nullable error))block NS_SWIFT_UNAVAILABLE("");

@end


