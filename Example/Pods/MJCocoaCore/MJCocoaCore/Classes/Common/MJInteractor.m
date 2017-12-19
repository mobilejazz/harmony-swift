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

#import "MJInteractor.h"

static NSMutableDictionary *_interactorDispatchQueues;

@interface MJInteractor ()

@property (nonatomic, assign, readwrite) BOOL refresh;

@end

@implementation MJInteractor
{
    dispatch_semaphore_t _semaphore;
}

@synthesize isExecuting = _isExecuting;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _interactorDispatchQueues = [[NSMutableDictionary alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _refresh = NO;
        
        NSString *className = NSStringFromClass(self.class);
        NSString *queueName = [NSString stringWithFormat:@"com.mobilejazz.core.interactor.%@", className];
        
        @synchronized(_interactorDispatchQueues)
        {
            dispatch_queue_t queue = _interactorDispatchQueues[queueName];
            if (!queue)
            {
                queue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
                _interactorDispatchQueues[queueName] = queue;
            }
            
            _queue = queue;
        }
    }
    return self;
}

#pragma mark Properties

- (void)setQueue:(dispatch_queue_t)queue
{
    if (queue == NULL)
    {
        [[NSException exceptionWithName:NSInvalidArgumentException reason:@"An interactor cannot work with a NULL queue." userInfo:nil] raise];
    }
    
    if (self.isExecuting == YES)
    {
        [[NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot set the queue while the interactor is being executed." userInfo:nil] raise];
    }
    
    _queue = queue;
}

#pragma mark Public Methods

- (void)begin:(void (^)(void))block
{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    dispatch_async(self.queue, ^{
        _semaphore = dispatch_semaphore_create(0);
        block();
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    });
}

- (void)end:(void (^)(void))block
{
    if ([NSThread isMainThread])
    {
        if (block)
        {
            block();
        }
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = NO;
        [self didChangeValueForKey:@"isExecuting"];
        if (_semaphore != NULL)
        {
            dispatch_semaphore_signal(_semaphore);
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block)
            {
                block();
            }
            [self willChangeValueForKey:@"isExecuting"];
            _isExecuting = NO;
            [self didChangeValueForKey:@"isExecuting"];
            if (_semaphore != NULL)
            {
                dispatch_semaphore_signal(_semaphore);
            }
        });
    }
    
    _refresh = NO;
}

- (void)end
{
    [self end:nil];
}

- (void)setNeedsRefresh
{
    _refresh = YES;
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (void)perform:(void (^)(void))block
{
    [self begin:^{
        block();
        [self end];
    }];
}

- (MJFuture*)performWithFuture:(void (^)(MJFuture *future))block
{
    MJFuture *future = [MJFuture emptyFuture];
    
    [future addObserver:self];
    
    [self begin:^{
        block(future);
    }];
    
    return future;
}

#pragma mark - Protocols
#pragma mark MJFutureObserver

- (void)future:(MJFuture *)future didSetValue:(id)value
{
    [self end];
}

- (void)future:(MJFuture *)future didSetError:(NSError *)error
{
    [self end];
}

- (void)wontHappenFuture:(MJFuture *)future
{
    [self end];
}

@end
