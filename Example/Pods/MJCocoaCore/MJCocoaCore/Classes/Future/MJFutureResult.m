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

#import "MJFutureResult.h"

@implementation MJFutureResult

+ (MJFutureResult*)resultWithValue:(id)value
{
    return [[MJFutureResult alloc] initWithValue:value];
}

+ (MJFutureResult*)resultWithError:(NSError *)error
{
    return [[MJFutureResult alloc] initWithError:error];
}

- (instancetype)initWithValue:(id)value
{
    self = [super init];
    if (self)
    {
        _type = MJFutureResultTypeValue;
        _value = value;
    }
    return self;
}

- (instancetype)initWithError:(NSError*)error
{
    self = [super init];
    if (self)
    {
        _type = MJFutureResultTypeError;
        _error = error;
    }
    return self;
}

@end
