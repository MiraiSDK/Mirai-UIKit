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

@interface NSArray (Indexing)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end
@interface NSMutableArray (Indexing)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end

// NSDictionary+Indexing.h
@interface  NSDictionary (Indexing)
- (id)objectForKeyedSubscript:(id)key;
@end
@interface  NSMutableDictionary (Indexing)
- (void)setObject:(id)obj forKeyedSubscript:(id)key;
@end

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
- (BOOL)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)error;
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

enum {
    NSSortConcurrent = (1UL << 0),
    NSSortStable = (1UL << 4),
};
typedef NSUInteger NSSortOptions;
typedef NSComparisonResult (^NSComparator)(id obj1, id obj2);
@interface NSArray (Android)

- (NSArray *)sortedArrayUsingComparator:(NSComparator)cmptr;
- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;

typedef NS_OPTIONS(NSUInteger, NSBinarySearchingOptions) {
	NSBinarySearchingFirstEqual = (1UL << 8),
	NSBinarySearchingLastEqual = (1UL << 9),
	NSBinarySearchingInsertionIndex = (1UL << 10),
};

- (NSUInteger)indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp;

@end

@interface NSDictionary (Android)
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;
- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block;

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

@interface NSSortDescriptor (Android)
+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending;
//+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector;

@end

@interface NSURL (Android)
+ (id)fileURLWithPath:(NSString *)path isDirectory:(BOOL) isDir;
@end

@interface NSIndexSet (Android)
- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger idx, BOOL *stop))block;
- (NSIndexSet *)indexesInRange:(NSRange)range options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate;

@end

@interface NSObject (Android)
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
@end

@interface NSObject(UINibLoadingAdditions)
- (void)awakeFromNib;
@end

typedef NS_OPTIONS(NSUInteger, NSDataWritingOptions) {
    NSDataWritingAtomic = 1UL << 0,	// Hint to use auxiliary file when saving; equivalent to atomically:YES
    NSDataWritingWithoutOverwriting = 1UL << 1, // Hint to  prevent overwriting an existing file. Cannot be combined with NSDataWritingAtomic.
    
    NSDataWritingFileProtectionNone = 0x10000000,
    NSDataWritingFileProtectionComplete = 0x20000000,
    NSDataWritingFileProtectionCompleteUnlessOpen = 0x30000000,
    NSDataWritingFileProtectionCompleteUntilFirstUserAuthentication = 0x40000000,
    NSDataWritingFileProtectionMask = 0xf0000000,
    
    // Options with old names for NSData writing methods. Please stop using these old names.
    //NSAtomicWrite = NSDataWritingAtomic	    // Deprecated name for NSDataWritingAtomic
};


CFIndex CFStringGetHyphenationLocationBeforeIndex(CFStringRef string, CFIndex location, CFRange limitRange, CFOptionFlags options, CFLocaleRef locale, UTF32Char *character);

