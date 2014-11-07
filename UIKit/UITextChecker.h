//
//  UITextChecker.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextChecker : NSObject
- (NSRange)rangeOfMisspelledWordInString:(NSString *)stringToCheck range:(NSRange)range startingAt:(NSInteger)startingOffset wrap:(BOOL)wrapFlag language:(NSString *)language;

- (NSArray *)guessesForWordRange:(NSRange)range inString:(NSString *)string language:(NSString *)language;

- (NSArray *)completionsForPartialWordRange:(NSRange)range inString:(NSString *)string language:(NSString *)language;

- (void)ignoreWord:(NSString *)wordToIgnore;
- (NSArray *)ignoredWords;
- (void)setIgnoredWords:(NSArray *)words;

+ (void)learnWord:(NSString *)word;
+ (BOOL)hasLearnedWord:(NSString *)word;
+ (void)unlearnWord:(NSString *)word;

+ (NSArray *)availableLanguages;

@end
