//
//  UIKit+Android.m
//  NextBook
//
//  Created by Chen Yonghui on 4/1/14.
//  Copyright (c) 2014 Shanghai TinyNetwork. All rights reserved.
//

#import "UIKit+Android.h"

#import <CoreFoundation/CoreFoundation.h>

@implementation NSString (Android)

- (void)enumerateSubstringsInRange:(NSRange)range options:(NSStringEnumerationOptions)opts usingBlock:(void (^)(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop))block
{
//    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
    
    BOOL isReverse = opts & NSStringEnumerationReverse;
    BOOL isLocalized = opts & NSStringEnumerationLocalized;
    BOOL isSubstringNotRequired = opts & NSStringEnumerationSubstringNotRequired;
    NSStringEnumerationOptions by = opts & 0x0001111111;
    
    NSUInteger length = self.length;
    NSRange subStringRange = NSMakeRange(0, length);

    if (by == NSStringEnumerationByWords) {
    } else if (by == NSStringEnumerationByLines) {
        
    } else {
        NSLog(@"%s unimplemented options:%d",__PRETTY_FUNCTION__, opts);
    }
    BOOL shouldStop = NO;
    @autoreleasepool {
        block(self,subStringRange,subStringRange,&shouldStop);
    }
    
}

@end

@interface NSBlockOperation ()
@property (nonatomic, strong) NSMutableArray *blocks;
@end
@implementation NSBlockOperation

+ (id)blockOperationWithBlock:(void (^)(void))block
{
    NSBlockOperation *op = [[self alloc] init];
    [op addExecutionBlock:block];
    
    return op;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _blocks = [NSMutableArray array];
    }
    return self;
}

- (void)addExecutionBlock:(void (^)(void))block
{
    [_blocks addObject:[block copy]];
}

- (NSArray *)executionBlocks
{
    return _blocks;
}

- (void)main
{
    for (void (^b)(void) in _blocks) {
        if (self.isCancelled) {
            break;
        }
        
        b();
    }
}

@end

@implementation NSOperationQueue (Android)

- (void)addOperationWithBlock:(void (^)(void))block
{
    NSBlockOperation *blockOP = [NSBlockOperation blockOperationWithBlock:block];
    [self addOperation:blockOP];
}

@end

@implementation NSURL (Android)

+ (id)fileURLWithPath:(NSString *)path isDirectory:(BOOL) isDir
{
    return [NSURL fileURLWithPath:path];
}

@end

@implementation NSString (NSURLUtilities)

- (NSString *)stringByAddingPercentEncodingWithAllowedCharacters:(NSCharacterSet *)allowedCharacters
{
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
    return self;
}

- (NSString *)stringByRemovingPercentEncoding
{
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation NSIndexSet (Android)

- (NSIndexSet *)indexesInRange:(NSRange)range options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate
{
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
    return nil;
}

- (void)enumerateRangesUsingBlock:(void (^)(NSRange range, BOOL *stop))block
{
    const NSUInteger firstIndex = [self firstIndex];
    const NSUInteger lastIndex = [self lastIndex];
    
    __block NSUInteger prevIdx = firstIndex;
    __block NSUInteger rangeStart = firstIndex;
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *idxStop) {
        if (idx > firstIndex ) {
            if (idx > prevIdx+1 || idx == lastIndex) {
                // meet new range
                
                NSRange prevRange = NSMakeRange(rangeStart, prevIdx - rangeStart + 1);
                BOOL shouldStop = NO;
                block(prevRange,&shouldStop);
                if (shouldStop) {
                    *idxStop = shouldStop;
                }
                
                rangeStart = idx;
            }
            
            prevIdx = idx;
        }
    }];
}
@end

@implementation NSObject (Android)

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
}

@end


CFIndex CFStringGetHyphenationLocationBeforeIndex(CFStringRef string, CFIndex location, CFRange limitRange, CFOptionFlags options, CFLocaleRef locale, UTF32Char *character)
{
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
    return 0;
}
