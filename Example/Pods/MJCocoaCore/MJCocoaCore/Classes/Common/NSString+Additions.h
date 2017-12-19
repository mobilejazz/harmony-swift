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

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define ADDColor UIColor
#define ADDFont UIFont
#else
#import <AppKit/AppKit.h>
#define ADDColor NSColor
#define ADDFont NSFont
#endif


/**
 * Additions on NSString
 **/
@interface NSString (Additions)

/** ************************************************************ **
 * @name Words
 ** ************************************************************ **/

/**
 * Return an array with all words.
 * @return An array of all words.
 **/
- (nonnull NSArray<NSString*>*)add_words;

/**
 * Returns the first word.
 * @return The first word.
 **/
- (nonnull NSString*)add_firstWord;

/**
 * Returns the last word.
 * @return The last word.
 **/
- (nonnull NSString*)add_lastWord;

/**
 * String by removing the first word
 * @return The string without the first word.
 **/
- (nonnull NSString*)add_stringByDeletingFirstWord;

/** ************************************************************ **
 * @name String generation
 ** ************************************************************ **/

/**
 * Returns an unique string based on CFUUIDCreate. This string can be used as an identifier
 * @return An unique string.
 **/
+ (nonnull NSString*)add_uniqueString;

/**
 * Creates a random string at least 10 chars long.
 * @return A random string.
 **/
+ (nonnull NSString*)add_randomString;

/**
 * Creates a random string with a specific length.
 * @return A random string of the given length.
 **/
+ (nonnull NSString*)add_randomStringWithLength:(NSUInteger)length;

/**
 * Creates a string from an array of components and join them with the given string.
 * @param components An array of strings to join
 * @param string The join string being placed in the middle of each component.
 * @return The new joined string.
 **/
+ (nonnull NSString*)add_stringWithComponents:(nonnull NSArray<NSString*>*)components joinedWithString:(nullable NSString*)string;

@end


/**
 * Additions on NSAttributedString
 **/
@interface NSAttributedString (Additions)

/** ************************************************************ **
 * @name Creating instances
 ** ************************************************************ **/

/**
 * Creates a new attributed string for the given string and attributes.
 * @param string The string.
 * @param attrs The string attributes.
 **/
+ (nonnull NSAttributedString*)add_attributedStringWithString:(nonnull NSString*)string attributes:(nonnull NSDictionary*)attrs;
/**
 * Creates a new attributed string for the given strings and attributes.
 * @param strings An array of strings.
 * @param attributes An array of attributes.
 * @discussion The array of attributes must have at least 1 entry. For the rest of attributes, the latest array dictionary of attributes will be reused.
 **/
+ (nonnull NSAttributedString*)add_attributedStringWithStrings:(nonnull NSArray*)strings attributes:(nonnull NSArray*)attributes;

/**
 * Creates a new attributed string for the given strings and fonts and colors.
 * @param strings An array of strings.
 * @param fonts An array of fonts.
 * @param colors An array of stringscolors.
 * @discussion The array of fonts and colors must have at least 1 entry. For the rest of fonts/colors, the latest array value  will be reused.
 **/
+ (nonnull NSAttributedString*)add_attributedStringWithStrings:(nonnull NSArray*)strings fonts:(nonnull NSArray<ADDFont*>*)fonts textColors:(nonnull NSArray<ADDColor*>*)colors;

/**
 * Creates a new attributed string for the given string, font and color.
 * @param string The string.
 * @param font The font.
 * @param color The color.
 **/
+ (nonnull NSAttributedString*)add_attributedStringWithString:(nonnull NSString*)string font:(nonnull ADDFont*)font textColor:(nonnull ADDColor*)color;

/** ************************************************************ **
 * @name Modifying strings
 ** ************************************************************ **/

/**
 * Uppercase the string.
 * @return A new attributed string uppercased.
 **/
- (nonnull NSAttributedString*)add_uppercaseAttrubutedString;

/**
 * Lowercase the string.
 * @return A new attributed string lowercased.
 **/
- (nonnull NSAttributedString*)add_lowercaseAttributedString;

@end
