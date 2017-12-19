//
// Copyright 2014 Mobile Jazz SL
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

typedef NS_ENUM(NSUInteger, MJAppLinkRecognizerResult)
{
    MJAppLinkRecognizerResultValid,
    MJAppLinkRecognizerResultUnknownScheme,
    MJAppLinkRecognizerResultUnsupportedLink,
};

typedef NS_ENUM(NSUInteger, MJAppLinkOptions)
{
    MJAppLinkOptionsNone            = 0,
    MJAppLinkOptionsAnchoredStart   = 1 << 0,
    MJAppLinkOptionsAnchoredEnd     = 1 << 1,
    MJAppLinkOptionsCaseInsensitive = 1 << 2,
};

extern NSString * const MJAppLinkPatternNumeric;
extern NSString * const MJAppLinkPatternNonNumeric;
extern NSString * const MJAppLinkPatternAlphanumeric;
extern NSString * const MJAppLinkPatternAlphanumericAndDash;

/**
 * Configuration class
 **/
@interface MJAppLinkRecognizerConfiguration : NSObject

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, assign) MJAppLinkOptions options;

- (void)setPattern:(NSString*)pattern forKey:(NSString*)key;
- (void)setForKey:(NSString*)key pattern:(NSString*)format, ...;

@end

@protocol MJAppLinkRecognizerObserver;
@protocol MJAppLinkRecognizerDelegate;

/**
 *
 **/
@interface MJAppLinkRecognizer : NSObject

- (id)initWithConfiguration:(void (^)(MJAppLinkRecognizerConfiguration *configuration))block;

- (BOOL)canHandleURL:(NSURL*)url;
- (MJAppLinkRecognizerResult)handleURL:(NSURL*)url;

- (void)addObserver:(id <MJAppLinkRecognizerObserver>)observer;
- (void)removeObserver:(id <MJAppLinkRecognizerObserver>)observer;

@property (nonatomic, weak) id <MJAppLinkRecognizerDelegate> delegate;

@end


/**
 * Observer
 **/
@protocol MJAppLinkRecognizerObserver <NSObject>

@optional
- (void)appLinkRecognizer:(MJAppLinkRecognizer*)recognizer didRecognizeURLForKey:(NSString*)key components:(NSArray*)components;
- (void)appLinkRecognizer:(MJAppLinkRecognizer*)recognizer didFailToRecognizeURL:(NSURL*)url result:(MJAppLinkRecognizerResult)result;

@end

/**
 * Delegate
 **/
@protocol MJAppLinkRecognizerDelegate <MJAppLinkRecognizerObserver>

@optional
- (BOOL)appLinkRecognizer:(MJAppLinkRecognizer*)recognizer willRecognizeURLForKey:(NSString*)key components:(NSArray*)components;

@end
