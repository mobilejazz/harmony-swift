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

typedef NS_ENUM(NSUInteger, MJFutureResultType)
{
    MJFutureResultTypeValue,
    MJFutureResultTypeError,
};

/**
 * An object encapsulating the result of a future.
 **/
@interface MJFutureResult<T> : NSObject

+ (MJFutureResult* _Nonnull)resultWithValue:(T _Nullable)value;
+ (MJFutureResult* _Nonnull)resultWithError:(NSError *_Nonnull)error;

- (instancetype _Nonnull)initWithValue:(T _Nullable)value;
- (instancetype _Nonnull)initWithError:(NSError* _Nonnull)error;

@property (nonatomic, assign, readonly) MJFutureResultType type;
@property (nonatomic, strong, readonly) T _Nullable value;
@property (nonatomic, strong, readonly) NSError *_Nullable error;

@end
