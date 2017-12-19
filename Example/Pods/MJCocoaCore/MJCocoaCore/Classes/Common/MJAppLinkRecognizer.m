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

#import "MJAppLinkRecognizer.h"

NSString * const MJAppLinkPatternNumeric                = @"(\\d+)";
NSString * const MJAppLinkPatternNonNumeric             = @"(\\D+)";
NSString * const MJAppLinkPatternAlphanumeric           = @"(\\w+)";
NSString * const MJAppLinkPatternAlphanumericAndDash    = @"([\\w,-]+)";

@interface MJAppLinkRecognizerConfiguration ()

- (NSDictionary*)patterns;

@end

@implementation MJAppLinkRecognizerConfiguration
{
    NSMutableDictionary *_patterns;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _scheme = nil;
        _patterns = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setPattern:(NSString*)pattern forKey:(NSString*)key
{
    _patterns[key] = [NSString stringWithFormat:@"%@", pattern];
}

- (void)setForKey:(NSString*)key pattern:(NSString*)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *pattern = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self setPattern:pattern forKey:key];
}

- (NSDictionary*)patterns
{
    return [_patterns copy];
}

@end

@implementation MJAppLinkRecognizer
{
    NSString *_scheme;
    NSDictionary <NSString*,NSString*> *_patterns;
    MJAppLinkOptions _options;
    
    NSHashTable <id<MJAppLinkRecognizerObserver>>*_observers;
}

- (id)init
{
    return [self initWithConfiguration:nil];
}

- (id)initWithConfiguration:(void (^)(MJAppLinkRecognizerConfiguration *configuration))block
{
    self = [super init];
    if (self)
    {
        MJAppLinkRecognizerConfiguration *configuration = [[MJAppLinkRecognizerConfiguration alloc] init];
        
        if (block)
            block(configuration);
        
        _scheme = configuration.scheme;
        _patterns = [configuration patterns];
        _options = configuration.options;
        
        _observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

#pragma mark Public Methods

- (BOOL)canHandleURL:(NSURL*)url
{
    MJAppLinkRecognizerResult result = [self mjz_handleURL:url notifyObservers:NO];
    return result == MJAppLinkRecognizerResultValid;
}

- (MJAppLinkRecognizerResult)handleURL:(NSURL*)url
{
    return [self mjz_handleURL:url notifyObservers:YES];
}

- (void)addObserver:(id <MJAppLinkRecognizerObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id <MJAppLinkRecognizerObserver>)observer
{
    [_observers removeObject:observer];
}

#pragma mark Private Methods

- (void)mjz_enumerateObservers:(void (^)(id<MJAppLinkRecognizerObserver> _Nonnull obj))block
{
    block(_delegate);
    
    [[_observers allObjects] enumerateObjectsUsingBlock:^(id<MJAppLinkRecognizerObserver> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj);
    }];
}

- (MJAppLinkRecognizerResult)mjz_handleURL:(NSURL*)url notifyObservers:(BOOL)notifyObservers
{
    if (_scheme != nil && ![url.scheme isEqualToString:_scheme])
    {
        if (notifyObservers)
        {
            [self mjz_enumerateObservers:^(id<MJAppLinkRecognizerObserver>  _Nonnull obj) {
                if ([obj respondsToSelector:@selector(appLinkRecognizer:didFailToRecognizeURL:result:)])
                    [obj appLinkRecognizer:self didFailToRecognizeURL:url result:MJAppLinkRecognizerResultUnknownScheme];
            }];
        }
        
        return MJAppLinkRecognizerResultUnknownScheme;
    }
    
    NSString *linkString = [url resourceSpecifier];
    
    NSRegularExpressionOptions regularExpressionOptions = 0;
    
    if ((_options & MJAppLinkOptionsCaseInsensitive) != 0)
        regularExpressionOptions |= NSRegularExpressionCaseInsensitive;
    
    for (NSString *patternKey in _patterns)
    {
        NSString *pattern = _patterns[patternKey];
        
        if ((_options & MJAppLinkOptionsAnchoredStart) != 0)
            pattern = [@"^" stringByAppendingString:pattern];
        
        if ((_options & MJAppLinkOptionsAnchoredEnd) != 0)
            pattern = [pattern stringByAppendingString:@"$"];
        
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:regularExpressionOptions
                                                                                 error:&error];
        
        NSTextCheckingResult *result = [regex firstMatchInString:linkString
                                                         options:0
                                                           range:NSMakeRange(0, linkString.length)];
        
        if (result)
        {
            NSMutableArray *captures = [NSMutableArray array];
            
            for (NSUInteger i = 1; i < result.numberOfRanges; i++)
            {
                NSRange range = [result rangeAtIndex:i];
                NSString *capture = [linkString substringWithRange:range];
                [captures addObject:capture];
            }
            
            NSArray *compontents = [captures copy];
            
            BOOL canRecognizePattern = YES;
            
            if ([_delegate respondsToSelector:@selector(appLinkRecognizer:willRecognizeURLForKey:components:)])
                canRecognizePattern = [_delegate appLinkRecognizer:self willRecognizeURLForKey:patternKey components:compontents];
            
            if (canRecognizePattern)
            {
                [self mjz_enumerateObservers:^(id<MJAppLinkRecognizerObserver>  _Nonnull obj) {
                    if ([obj respondsToSelector:@selector(appLinkRecognizer:didRecognizeURLForKey:components:)])
                        [obj appLinkRecognizer:self didRecognizeURLForKey:patternKey components:compontents];
                }];
                
                return MJAppLinkRecognizerResultValid;
            }
        }
    }
    
    [self mjz_enumerateObservers:^(id<MJAppLinkRecognizerObserver>  _Nonnull obj) {
        if ([obj respondsToSelector:@selector(appLinkRecognizer:didFailToRecognizeURL:result:)])
            [obj appLinkRecognizer:self didFailToRecognizeURL:url result:MJAppLinkRecognizerResultUnsupportedLink];
    }];
    
    return MJAppLinkRecognizerResultUnsupportedLink;
}

@end
