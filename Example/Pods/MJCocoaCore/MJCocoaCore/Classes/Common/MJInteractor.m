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
#import "MJExecutor.h"

static NSMutableDictionary *_executors;

@interface MJInteractor ()

@property (nonatomic, assign, readwrite) BOOL refresh;

@end

@implementation MJInteractor
{
    void (^_end)(void);
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _executors = [[NSMutableDictionary alloc] init];
    });
}

- (id)init
{
    @synchronized(_executors)
    {
        NSString *key = NSStringFromClass(self.class);
        MJExecutor *executor = _executors[key];
        if (!executor)
        {
            NSString *queueName = [NSString stringWithFormat:@"com.mobilejazz.core.interactor.%@", key];
            dispatch_queue_t queue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
            executor = [[MJExecutor alloc] initWithQueue:queue];
            _executors[key] = executor;
        }
        return [self initWithExecutor:executor];
    }
}

- (instancetype)initWithExecutor:(MJExecutor *)executor
{
    self = [super init];
    if (self)
    {
        _refresh = NO;
        _executor = executor;
    }
    return self;
}

#pragma mark Public Methods

- (void)begin:(void (^)(void))block
{
    [_executor submit:^(void (^ _Nonnull end)(void)) {
        self->_end = end;
        block();
    }];
}

- (void)end:(void (^)(void))block
{
    if ([NSThread isMainThread])
    {
        block();
        [self end];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
            [self end];
        });
    }
}

- (void)end
{
    void (^end)(void) = _end;
    _end = nil;
    _refresh = NO;
    end();
}

- (void)setNeedsRefresh
{
    _refresh = YES;
}

- (BOOL)isExecuting
{
    return _executor.isExecuting;
}

- (MJFuture*)performWithFuture:(void (^)(MJFuture *future))block
{
    return [_executor ft_submit:^(MJFuture * _Nonnull future) {
        block(future);
    }];
}

@end

