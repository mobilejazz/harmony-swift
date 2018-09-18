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

#import "MJFutureBatch.h"
#import "MJFuture.h"

@interface MJFutureContextualResult <T> : NSObject

@property (nonatomic, strong) T object;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id context;
@property (nonatomic, assign) BOOL completed;

@end

@implementation MJFutureContextualResult

@end

@implementation MJFutureBatch
{
    void (^_Nullable _thenBlock)(_Nullable id object, NSError *_Nullable error, id _Nullable context);
    void (^_Nullable _completionBlock)(NSError * _Nullable error, id _Nullable context);

    NSInteger _counter;
    NSMutableArray <MJFutureContextualResult*> *_results;
    MJFutureContextualResult *_errorResult;
    
    NSInteger _serialDeliveryIndex;
}

- (instancetype)init
{
    return [self initSerial:NO];
}

- (instancetype)initSerial:(BOOL)serial
{
    self = [super init];
    if (self)
    {
        _serial = serial;
        _results = [NSMutableArray array];
        _serialDeliveryIndex = 0;
    }
    return self;
}


#pragma mark Public Methods

+ (MJFutureBatch*)emptyBatch
{
    return [[MJFutureBatch alloc] initSerial:NO];
}

+ (MJFutureBatch*)emptySerialBatch
{
    return [[MJFutureBatch alloc] initSerial:YES];
}

- (void)batchFuture:(MJFuture * _Nonnull)future
{
    [self batchFuture:future context:nil];
}

- (void)batchFuture:(MJFuture * _Nonnull)future context:(id _Nullable)context
{
    @synchronized (self)
    {
        _counter++;
    }
    
    if (_serial)
    {
        MJFutureContextualResult *result = [MJFutureContextualResult new];
        [_results addObject:result];
    }
    
    NSInteger serialIndex = _results.count - 1;
    
    [future then:^(id  _Nullable object, NSError * _Nullable error) {
        
        @synchronized (self)
        {
            self->_counter--;
            
            MJFutureContextualResult *result = nil;
            
            if (self->_serial)
            {
                result = self->_results[serialIndex];
                result.completed = YES;
            }
            else
            {
                result = [MJFutureContextualResult new];
                [self->_results addObject:result];
            }
            
            result.object = object;
            result.error = error;
            result.context = context;
            
            if (!self->_errorResult && error != nil)
                self->_errorResult = result;
            
            [self mjz_updateStatus];
        }
    }];
}

- (MJFutureBatch * _Nonnull)then:(void (^ _Nonnull)(_Nullable id object, NSError *_Nullable error, id _Nullable context))block
{
    _thenBlock = block;
    [self mjz_updateStatus];
    return self;
}

- (void)completion:(void (^_Nonnull)(NSError * _Nullable error, id _Nullable context))completion
{
    _completionBlock = completion;
    [self mjz_updateStatus];
}

#pragma mark Private Methods

- (void)mjz_updateStatus
{
    if (_thenBlock)
    {
        if (_serial)
        {
            for (NSInteger i=_serialDeliveryIndex; i<_results.count; ++i)
            {
                MJFutureContextualResult *result = _results[i];
                if (result.completed)
                {
                    _thenBlock(result.object, result.error, result.context);
                    _serialDeliveryIndex = i+1;
                }
                else
                {
                    break;
                }
            }
        }
        else
        {
            NSMutableArray <MJFutureContextualResult*> *results = _results;
            _results = [NSMutableArray array];
            
            [results enumerateObjectsUsingBlock:^(MJFutureContextualResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                self->_thenBlock(obj.object, obj.error, obj.context);
            }];
        }
    }
    
    if (_completionBlock && _counter == 0)
    {
        _completionBlock(_errorResult.error, _errorResult.context);
        _errorResult = nil;
    }
}

@end
