//
//  UITextChecker.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITextChecker.h"

@implementation UITextChecker
- (NSRange)rangeOfMisspelledWordInString:(NSString *)stringToCheck range:(NSRange)range startingAt:(NSInteger)startingOffset wrap:(BOOL)wrapFlag language:(NSString *)language
{
    return NSMakeRange(NSNotFound, 0);
}

- (NSArray *)guessesForWordRange:(NSRange)range inString:(NSString *)string language:(NSString *)language
{
    return @[];
}

- (NSArray *)completionsForPartialWordRange:(NSRange)range inString:(NSString *)string language:(NSString *)language
{
    return @[];
}

- (void)ignoreWord:(NSString *)wordToIgnore
{
    
}

- (NSArray *)ignoredWords
{
    return @[];
}

- (void)setIgnoredWords:(NSArray *)words
{
    
}

+ (void)learnWord:(NSString *)word
{
    
}

+ (BOOL)hasLearnedWord:(NSString *)word
{
    return NO;
}

+ (void)unlearnWord:(NSString *)word
{
    
}

+ (NSArray *)availableLanguages
{
    return @[];
}
@end
