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
#import "MJExecutor.h"

@implementation MJExecutor
{
    dispatch_queue_t _queue;
    dispatch_semaphore_t _semaphore;
}

- (instancetype)init
{
    return [self initWithQueue:dispatch_get_main_queue()];
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self)
    {
        _queue = queue;
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)submit:(void (^)(void (^end)(void)))block
{
    if (_queue)
    {
        dispatch_async(_queue, ^{
            self->_executing = YES;
            block(^{
                dispatch_semaphore_signal(self->_semaphore);
            });
            dispatch_semaphore_wait(self->_semaphore, DISPATCH_TIME_FOREVER);
            self->_executing = NO;
        });
    }
    else
    {
        _executing = YES;
        block(^{ });
        _executing = NO;
    }
}

@end

@implementation MJExecutor (MJFuture)

- (MJFuture*)ft_submit:(void (^)(MJFuture *))block
{
    MJFuture *future = [MJFuture emptyFuture];
    [self submit:^(void (^end)(void)) {
        [future onSet:^(__strong id  _Nullable * _Nonnull value, NSError *__strong  _Nullable * _Nonnull error) {
            end();
        }];
        @try
        {
            block(future);
        }
        @catch (NSException *exception)
        {
            NSError *error = exception.userInfo[MJFutureErrorKey];
            if (error)
            {
                [future setError:error];
            }
            else
            {
                @throw exception;
            }
        }
    }];
    // Returning in main que a new future, to avoid reseting the onSetBlock property.
    return [[MJFuture futureWithFuture:future] inMainQueue];
}

@end

