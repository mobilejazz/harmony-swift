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

#import "ObjC.h"

@implementation ObjC

+ (void)try:(void(^)(void))try catch:(void(^)(NSException*exception))catch
{
    @try {
        try ? try() : nil;
    }
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
}

+ (void)try:(void(^)(void))try catch:(void(^)(NSException*exception))catch finally:(void(^)(void))finally
{
    @try {
        try ? try() : nil;
    }
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
    @finally {
        finally ? finally() : nil;
    }
}

+ (NSString*)buildDate
{
    return [NSString stringWithUTF8String:__DATE__];
}

+ (NSString*)buildTime
{
    return [NSString stringWithUTF8String:__TIME__];
}

@end
