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

#import "MJFutureHub.h"
#import "MJFuture.h"

@implementation MJFutureHub
{
    NSLock *_lock;
    BOOL _reactive;
    NSHashTable <MJFuture*>*_weakFutures;
    NSMutableArray <MJFuture*> *_strongFutures;
}

+ (MJFutureHub * _Nonnull)hub
{
    return [[MJFutureHub alloc] initWithFuture:nil];
}

+ (MJFutureHub * _Nonnull)hubWithFuture:(MJFuture * _Nonnull)future
{
    return [[MJFutureHub alloc] initWithFuture:future];
}

- (instancetype)init
{
    return [self initWithFuture:nil];
}

- (instancetype)initWithFuture:(MJFuture *)future
{
    self = [super init];
    if (self)
    {
        _reactive = future!=nil?future.reactive:YES;
        _lock = [[NSLock alloc] init];
        _strongFutures = [NSMutableArray array];
        _weakFutures = [NSHashTable weakObjectsHashTable];
        
        // Using the setter method
        self.future = future;
    }
    return self;
}

#pragma mark Properties

- (void)setFuture:(MJFuture *)future
{
    _future  = future;
    [self update];
}

#pragma mark Public Methods

- (MJFuture *)plug
{
    return [self plugAs:MJFutureMemoryReferenceTypeWeak];
}

- (MJFuture *)plugAs:(MJFutureMemoryReferenceType)type
{
    MJFuture *future = [[MJFuture alloc] initReactive:_reactive];
    [self plug:future as:type];
    return future;
}

- (void)plug:(MJFuture *)future
{
    [self plug:future as:MJFutureMemoryReferenceTypeWeak];
}

- (void)plug:(MJFuture *)future as:(MJFutureMemoryReferenceType)type
{
    [_lock lock];
    switch (type)
    {
        case MJFutureMemoryReferenceTypeStrong:
            [_strongFutures addObject:future];
            break;
        case MJFutureMemoryReferenceTypeWeak:
            [_weakFutures addObject:future];
            break;
    }
    [_lock unlock];
}

- (void)unplug:(MJFuture *)future
{
    [_lock lock];
    [_weakFutures removeObject:future];
    [_strongFutures removeObjectIdenticalTo:future];
    [_lock unlock];
}

- (void)unplugAll
{
    [_lock lock];
    [_weakFutures removeAllObjects];
    [_strongFutures removeAllObjects];
    [_lock unlock];
}

#pragma mark Private Methods

- (void)update
{
    if (!_future)
        return;
    
    _reactive = _future.reactive;
    
    [_lock lock];
    for (MJFuture *future in _weakFutures.allObjects)
    {
        [future mimic:_future];
    }
    for (MJFuture *future in _strongFutures.copy)
    {
        [future mimic:_future];
    }
    [_lock unlock];
    
    [_future then:^(id  _Nullable object, NSError * _Nullable error) {
        [_lock lock];
        for (MJFuture *future in _weakFutures.allObjects)
        {
            [future setValue:object error:error];
        }
        for (MJFuture *future in _strongFutures.copy)
        {
            [future setValue:object error:error];
        }
        [_lock unlock];
    }];
}

@end
