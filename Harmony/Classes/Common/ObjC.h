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

/**
 Set of methods to manipulate C or Objective-C code from Swift.
 */
@interface ObjC : NSObject

/**
 A try-catch method to catch the exception from Swift.

 @param try The try block
 @param catch The catch block
 */
+ (void)try:(void(^_Nonnull)(void))try catch:(void(^_Nonnull)(NSException*_Nonnull))catch;

/**
 A try-catch method to catch the exception from Swift.
 
 @param try The try block
 @param catch The catch block
 @param finally The finally block
 */
+ (void)try:(void(^_Nonnull)(void))try catch:(void(^_Nonnull)(NSException*_Nonnull))catch finally:(void(^_Nonnull)(void))finally;

/**
 Returns the build date from the C macro __DATE__.

 @return The build date.
 */
+ (NSString* _Nonnull)buildDate;

/**
 Returns the build dtime from the C macro __TIME__.

 @return The build time.
 */
+ (NSString* _Nonnull)buildTime;

@end
