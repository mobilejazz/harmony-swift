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

#import <Foundation/Foundation.h>

/**
 * Secure key generation (keychain storage).
 **/
@interface MJSecureKey : NSObject

/**
 * Default static initializer.
 * @param identifier The identifier of the key.
 * @param length The length of the key.
 * @return An initialized instance.
 **/
+ (MJSecureKey*)secureKeyWithIdentifier:(NSString*)identifier length:(size_t)length;

/**
 * Default initializer.
 * @param identifier The identifier of the key.
 * @param length The length of the key.
 * @return The initialized instance.
 **/
- (id)initWithIdentifier:(NSString*)identifier length:(size_t)length;

/**
 * Resets the stored key to a new random key.
 * @return YES if succeed, NO otherwise.
 **/
- (BOOL)reset;

/**
 * Clears the stored key.
 * @return YES if succeed, NO otherwise.
 **/
- (BOOL)clear;

/**
 * Returns the stored key or generates a new one if not stored.
 * @return The random key.
 * @discussion If error, the returned key is nil.
 **/
- (NSData*)key;

@end
