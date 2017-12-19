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

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (NSArray*)add_words
{
    NSArray *words = [self componentsSeparatedByString:@" "];
    return words;
}

- (NSString*)add_firstWord
{
    NSArray *words = [self add_words];
    
    if (words.count > 0)
        return [words objectAtIndex:0];
    
    return [self copy];
}

- (NSString*)add_lastWord
{
    return [[self add_words] lastObject];
}

- (NSString*)add_stringByDeletingFirstWord
{
    NSArray *words = [self add_words];
    
    if (words.count > 0)
    {
        NSString *firstWord = [words firstObject];
        
        if (firstWord.length + 1 < self.length)
            return [self stringByReplacingCharactersInRange:NSMakeRange(0, firstWord.length + 1) withString:@""];
    }
    
    return nil;
}

+ (NSString*)add_uniqueString
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString  *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

+ (NSString*)add_randomString
{
    return [self add_randomStringWithLength:(arc4random()%10 + 10)];
}

+ (NSString*)add_randomStringWithLength:(NSUInteger)length
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *string = [NSMutableString stringWithCapacity:length];
    
    for (NSUInteger index = 0U; index < length; index++)
    {
        u_int32_t randomIndex = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:randomIndex];
        [string appendFormat:@"%C", c];
    }
    
    return [string copy];
}

+ (nonnull NSString*)add_stringWithComponents:(nonnull NSArray<NSString*>*)components joinedWithString:(nullable NSString*)string
{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (NSInteger index = 0; index<components.count; ++index)
    {
        NSString *cmpt = components[index];
        [str appendString:cmpt];
        if (index < components.count - 1)
            [str appendString:string];
    }
    
    return [str copy];
}

@end

@implementation NSAttributedString (Additions)

+ (NSAttributedString*)add_attributedStringWithString:(NSString*)string attributes:(NSDictionary*)attrs
{
    return [[NSAttributedString alloc] initWithString:string attributes:attrs];
}

+ (NSAttributedString*)add_attributedStringWithStrings:(NSArray*)strings attributes:(NSArray*)attributes
{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    
    NSInteger stringsCount = strings.count;
    NSInteger attributesCount = attributes.count;
    
    for (NSInteger index = 0; index < stringsCount; ++index)
    {
        NSString *string = strings[index];
        
        NSDictionary *attr = nil;
        
        if (index < attributesCount)
        {
            attr = attributes[index];
        }
        else if (attributesCount > 0)
        {
            attr = attributes[attributesCount-1];
        }
        
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attr];
        
        [mutableAttributedString appendAttributedString:attrString];
    }
    
    return [mutableAttributedString copy];
}

+ (NSAttributedString*)add_attributedStringWithStrings:(NSArray*)strings fonts:(NSArray*)fonts textColors:(NSArray*)colors
{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    
    NSInteger stringsCount = strings.count;
    NSInteger fontsCount = fonts.count;
    NSInteger colorsCount = colors.count;
    
    for (NSInteger index = 0; index < stringsCount; ++index)
    {
        NSString *string = strings[index];
        
        ADDFont *font = nil;
        if (index < fontsCount)
            font = fonts[index];
        else if (fontsCount > 0)
            font = fonts[fontsCount-1];
        
        ADDColor *color = nil;
        if (index < colorsCount)
            color = colors[index];
        else if (colorsCount > 0)
            color = colors[colorsCount-1];
        
        NSAttributedString *attrString = [NSAttributedString add_attributedStringWithString:string font:font textColor:color];
        [mutableAttributedString appendAttributedString:attrString];
    }
    
    return [mutableAttributedString copy];
}

+ (NSAttributedString*)add_attributedStringWithString:(NSString*)str font:(ADDFont*)font textColor:(ADDColor*)color
{
    NSDictionary *attributes = @{NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : color};
    
    return [[NSAttributedString alloc] initWithString:str attributes:attributes];
}

- (NSAttributedString*)add_uppercaseAttrubutedString;
{
    //Make a mutable copy of your input string
    NSMutableAttributedString *attrString = [self mutableCopy];
    
    //Make a mutable array
    NSMutableArray *array = [NSMutableArray array];
    
    //Add each set of attributes to the array in a dictionary containing the attributes and range
    [attrString enumerateAttributesInRange:NSMakeRange(0, attrString.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *dict = @{@"attrs": attrs,
                               @"range":[NSValue valueWithRange:range]};
        [array addObject:dict];
    }];
    
    //Make a plain uppercase string
    NSString *string = [attrString.string uppercaseString];
    
    //Replace the characters with the uppercase ones
    [attrString replaceCharactersInRange:NSMakeRange(0, attrString.length) withString:string];
    
    //Reapply each attribute
    for (NSDictionary *dict in array)
        [attrString setAttributes:[dict objectForKey:@"attrs"] range:[[dict objectForKey:@"range"] rangeValue]];
    
    return [attrString copy];
}

- (NSAttributedString*)add_lowercaseAttributedString
{
    //Make a mutable copy of your input string
    NSMutableAttributedString *attrString = [self mutableCopy];
    
    //Make a mutable array
    NSMutableArray *array = [NSMutableArray array];
    
    //Add each set of attributes to the array in a dictionary containing the attributes and range
    [attrString enumerateAttributesInRange:NSMakeRange(0, attrString.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *dict = @{@"attrs": attrs,
                               @"range":[NSValue valueWithRange:range]};
        [array addObject:dict];
    }];
    
    //Make a plain lowercase string
    NSString *string = [attrString.string lowercaseString];
    
    //Replace the characters with the uppercase ones
    [attrString replaceCharactersInRange:NSMakeRange(0, attrString.length) withString:string];
    
    //Reapply each attribute
    for (NSDictionary *dict in array)
        [attrString setAttributes:[dict objectForKey:@"attrs"] range:[[dict objectForKey:@"range"]rangeValue]];
    
    return [attrString copy];
}

@end
