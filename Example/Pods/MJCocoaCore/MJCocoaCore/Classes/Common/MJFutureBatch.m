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

@interface MJFutureResult : NSObject

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id context;

@end

@implementation MJFutureResult

@end

@implementation MJFutureBatch
{
    void (^_Nullable _thenBlock)(_Nullable id object, NSError *_Nullable error, id _Nullable context);
    void (^_Nullable _completionBlock)(NSError * _Nullable error, id _Nullable context);

    NSInteger _counter;
    NSMutableArray <MJFutureResult*> *_results;
    MJFutureResult *_errorResult;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _results = [NSMutableArray array];
    }
    return self;
}

#pragma mark Public Methods

+ (MJFutureBatch*)emptyBatch
{
    return [[MJFutureBatch alloc] init];
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
    
    [future then:^(id  _Nullable object, NSError * _Nullable error) {
        
        @synchronized (self)
        {
            _counter--;
            
            MJFutureResult *result = [MJFutureResult new];
            result.object = object;
            result.error = error;
            result.context = context;
            
            [_results addObject:result];
            
            if (!_errorResult && error != nil)
                _errorResult = result;
            
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
        NSMutableArray <MJFutureResult*> *results = _results;
        _results = [NSMutableArray array];
        
        [results enumerateObjectsUsingBlock:^(MJFutureResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _thenBlock(obj.object, obj.error, obj.context);
        }];
    }
    
    if (_completionBlock && _counter == 0)
    {
        _completionBlock(_errorResult.error, _errorResult.context);
        _errorResult = nil;
    }
}

@end
