//
//  UIKit+Android.h
//  NextBook
//
//  Temp file to add missing function
//  should move down to base framework
//
//  Created by Chen Yonghui on 4/1/14.
//  Copyright (c) 2014 Shanghai TinyNetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <CoreFoundation/CoreFoundation.h>

typedef NS_OPTIONS(NSUInteger, NSStringEnumerationOptions) {
    // Pass in one of the "By" options:
    NSStringEnumerationByLines = 0,                       // Equivalent to lineRangeForRange:
    NSStringEnumerationByParagraphs = 1,                  // Equivalent to paragraphRangeForRange:
    NSStringEnumerationByComposedCharacterSequences = 2,  // Equivalent to rangeOfComposedCharacterSequencesForRange:
    NSStringEnumerationByWords = 3,
    NSStringEnumerationBySentences = 4,
    // ...and combine any of the desired additional options:
    NSStringEnumerationReverse = 1UL << 8,
    NSStringEnumerationSubstringNotRequired = 1UL << 9,
    NSStringEnumerationLocalized = 1UL << 10              // User's default locale
};

@interface NSString (Android)
- (void)enumerateSubstringsInRange:(NSRange)range options:(NSStringEnumerationOptions)opts usingBlock:(void (^)(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop))block;
//- (void)enumerateLinesUsingBlock:(void (^)(NSString *line, BOOL *stop))block;
@end

@interface NSFileManager (Android)
- (NSArray *)URLsForDirectory:(NSSearchPathDirectory)directory inDomains:(NSSearchPathDomainMask)domainMask;
@end

typedef NS_OPTIONS(NSUInteger, NSAttributedStringEnumerationOptions) {
    NSAttributedStringEnumerationReverse = (1UL << 1),
    NSAttributedStringEnumerationLongestEffectiveRangeNotRequired = (1UL << 20)
};
@interface NSAttributedString (Android)
- (void)enumerateAttributesInRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary *attrs, NSRange range, BOOL *stop))block;
- (void)enumerateAttribute:(NSString *)attrName inRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id value, NSRange range, BOOL *stop))block;

@end

@interface NSBlockOperation : NSOperation {
@private
    id _private2;
    void *_reserved2;
}

//#if NS_BLOCKS_AVAILABLE
+ (id)blockOperationWithBlock:(void (^)(void))block;

- (void)addExecutionBlock:(void (^)(void))block;
- (NSArray *)executionBlocks;
//#endif

@end

@interface NSOperationQueue (Android)
//#if NS_BLOCKS_AVAILABLE
- (void)addOperationWithBlock:(void (^)(void))block;
//#endif

@end

@interface NSURL (Android)
+ (id)fileURLWithPath:(NSString *)path isDirectory:(BOOL) isDir;
@end

@interface NSIndexSet (Android)
- (NSIndexSet *)indexesInRange:(NSRange)range options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate;

@end

@interface NSObject (Android)
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
@end

@interface NSObject(UINibLoadingAdditions)
- (void)awakeFromNib;
@end

CFIndex CFStringGetHyphenationLocationBeforeIndex(CFStringRef string, CFIndex location, CFRange limitRange, CFOptionFlags options, CFLocaleRef locale, UTF32Char *character);

