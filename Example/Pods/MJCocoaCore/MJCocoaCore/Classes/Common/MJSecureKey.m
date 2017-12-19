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

#import "MJSecureKey.h"

@implementation MJSecureKey
{
    NSString *_identifier;
    size_t _length;
}

+ (MJSecureKey*)secureKeyWithIdentifier:(NSString*)identifier length:(size_t)length
{
    MJSecureKey *secureKey = [[MJSecureKey alloc] initWithIdentifier:identifier length:length];
    return secureKey;
}

- (id)initWithIdentifier:(NSString*)identifier length:(size_t)length
{
    self = [super init];
    if (self)
    {
        _identifier = identifier;
        _length = length;
    }
    return self;
}

- (BOOL)reset
{
    NSData *tag = [_identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t buffer[_length];
    int result = SecRandomCopyBytes(kSecRandomDefault, _length, buffer);
    if (result == -1)
        NSLog(@"Error executing SecRandomCopyBytes() method");
    
    NSData *keyData = [[NSData alloc] initWithBytes:buffer length:sizeof(buffer)];
    
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            };
    
    NSDictionary *attributesToUpdate = @{(__bridge id)kSecValueData: keyData};
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
    
    if (status == errSecSuccess)
        return YES;
    
    return NO;
}

- (BOOL)clear
{
    NSData *tag = [_identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            };
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status == errSecSuccess)
        return YES;
    
    return NO;
}

- (NSData*)key
{
    NSData *tag = [_identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    // First check in the keychain for an existing key
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @(_length),
                            (__bridge id)kSecReturnData: @YES};
    
    CFTypeRef dataRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataRef);
    
    if (status == errSecSuccess)
    {
        // If reading is successful
        NSData *data = (__bridge NSData *)dataRef;
        return data;
    }
    else if (status == -25308 /*errKCInteractionNotAllowed*/)
    {
        // If reading fails because app is not allowed
        // Fix cannot be applied because we cannot read the current keychain item.
        // Only option: crash app.
        
        [[NSException exceptionWithName:@"PWInvalidKeychainAccess"
                                 reason:@"The keychain couldn't be accessed because the device is locked."
                               userInfo:nil] raise];
        
        return nil;
    }
    else
    {
        // If no pre-existing key from this application
        
        uint8_t buffer[_length];
        int result = SecRandomCopyBytes(kSecRandomDefault, _length, buffer);
        if (result == -1)
            NSLog(@"Error executing SecRandomCopyBytes() method");
        
        NSData *keyData = [[NSData alloc] initWithBytes:buffer length:sizeof(buffer)];
        
        // Store the key in the keychain
        query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                  (__bridge id)kSecAttrApplicationTag: tag,
                  (__bridge id)kSecAttrKeySizeInBits: @(_length),
                  (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAlways,
                  (__bridge id)kSecValueData: keyData};
        
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        
        NSAssert(status == errSecSuccess, @"Failed to insert new key in the keychain with OSStatus (%d)", (int)status);
        
        return keyData;
    }
    
    return nil;
}

@end
