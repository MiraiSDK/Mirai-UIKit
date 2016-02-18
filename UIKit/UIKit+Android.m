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
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
    
    BOOL isReverse = opts & NSStringEnumerationReverse;
    BOOL isLocalized = opts & NSStringEnumerationLocalized;
    BOOL isSubstringNotRequired = opts & NSStringEnumerationSubstringNotRequired;
    NSStringEnumerationOptions by = opts & 0x0001111111;
    
    NSUInteger length = self.length;
    NSRange subStringRange = NSMakeRange(0, length);

    if (by == NSStringEnumerationByWords) {
    } else if (by == NSStringEnumerationByLines) {
        
    } else {
        NSLog(@"unimplemented options:%d",opts);
    }
    BOOL shouldStop = NO;
    @autoreleasepool {
        block(self,subStringRange,subStringRange,&shouldStop);
    }
    
}

@end
@implementation NSFileManager (Android)
- (NSArray *)URLsForDirectory:(NSSearchPathDirectory)directory inDomains:(NSSearchPathDomainMask)domainMask
{
    if (domainMask != NSUserDomainMask) {
        NSLog(@"currentlly only support NSUserDomainMask!");
        return @[];
    }
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [bundlePath stringByDeletingLastPathComponent];
    NSString *result = nil;
    switch (directory) {
        case NSCachesDirectory:
            result = [path stringByAppendingPathComponent:@"Library/Caches"];
            break;
        case NSDocumentDirectory:
            result = [path stringByAppendingPathComponent:@"Documents"];
            break;
        case NSLibraryDirectory:
            result = [path stringByAppendingPathComponent:@"Library"];
            break;
        case NSApplicationDirectory:
            result = [path stringByAppendingPathComponent:@"Applications"];
            break;
        case NSDocumentationDirectory:
            result = [path stringByAppendingPathComponent:@"Library/Documentation"];
            break;
        case NSDesktopDirectory:
            result = [path stringByAppendingPathComponent:@"Desktop"];
            break;
        case NSApplicationSupportDirectory:
            result = [path stringByAppendingPathComponent:@"Library/Application Support"];
            break;
        case NSDownloadsDirectory:
            result = [path stringByAppendingPathComponent:@"Downloads"];
            break;
            
        case NSDemoApplicationDirectory:
            result = [path stringByAppendingPathComponent:@"Applications/Demos"];
            break;
        case NSDeveloperApplicationDirectory:
            result = [path stringByAppendingPathComponent:@"Developer/Applications"];
            break;
        case NSAdminApplicationDirectory:
            result = [path stringByAppendingPathComponent:@"Applications/Utilities"];
            break;
        case NSDeveloperDirectory:
            result = [path stringByAppendingPathComponent:@"Developer"];
            break;
//        case NSAutosavedInformationDirectory:
//            result = [path stringByAppendingPathComponent:@"Library/Autosave Information"];
//            break;
//        case NSInputMethodsDirectory:
//            result = [path stringByAppendingPathComponent:@"Library/Input Methods"];
//            break;
//        case NSMoviesDirectory:
//            result = [path stringByAppendingPathComponent:@"Movies"];
//            break;
//        case NSMusicDirectory:
//            result = [path stringByAppendingPathComponent:@"Music"];
//            break;
//        case NSPicturesDirectory:
//            result = [path stringByAppendingPathComponent:@"Pictures"];
//            break;
//        case NSSharedPublicDirectory:
//            result = [path stringByAppendingPathComponent:@"Public"];
//            break;
//        case NSSharedPublicDirectory:
//            result = [path stringByAppendingPathComponent:@"Library/PreferencePanes"];
//            break;
            
        case NSUserDirectory:
//        case NSPrinterDescriptionDirectory:
//        case NSItemReplacementDirectory:
            result = nil;
            break;
            
        case NSAllApplicationsDirectory:
            return @[[path stringByAppendingPathComponent:@"Applications"],
                     [path stringByAppendingPathComponent:@"Applications/Utilities"],
                     [path stringByAppendingPathComponent:@"Developer/Applications"],
                     [path stringByAppendingPathComponent:@"Applications/Demos"]];
            break;
        case NSAllLibrariesDirectory:
            return @[[path stringByAppendingPathComponent:@"Library"],
                     [path stringByAppendingPathComponent:@"Developer"]];
            break;
        default:
            NSLog(@"unknow search path directory:%d",directory);
            break;
    }
    if (result) {
        NSLog(@"%@",result);
        return @[[NSURL fileURLWithPath:result]];
    }
    
    return @[];
}

@end

@implementation NSAttributedString (Android)
- (void)enumerateAttributesInRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary *attrs, NSRange range, BOOL *stop))block
{
    BOOL isLongestEffectiveRangeNotRequired = opts & NSAttributedStringEnumerationLongestEffectiveRangeNotRequired;
    BOOL isReverse = opts & NSAttributedStringEnumerationReverse;
    if (isReverse) {
        NSLog(@"NSAttributedStringEnumerationReverse option unimplemented");
    }

    BOOL shouldStop = NO;
    NSInteger pos = enumerationRange.location;
    NSInteger end = NSMaxRange(enumerationRange);
    
    while (pos < end) {
        NSRange effectiveRange;
        NSDictionary *attributes = nil;
        
        if (isLongestEffectiveRangeNotRequired) {
            attributes = [self attributesAtIndex:enumerationRange.location effectiveRange:&effectiveRange];
        } else {
            attributes = [self attributesAtIndex:pos longestEffectiveRange:&effectiveRange inRange:enumerationRange];
        }

        block(attributes,effectiveRange,&shouldStop);
        
        pos = NSMaxRange(effectiveRange);
        if (shouldStop) {
            break;
        }
    }
}

- (void)enumerateAttribute:(NSString *)attrName inRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id, NSRange, BOOL *))block
{
    BOOL isLongestEffectiveRangeNotRequired = opts & NSAttributedStringEnumerationLongestEffectiveRangeNotRequired;
    BOOL isReverse = opts & NSAttributedStringEnumerationReverse;
    
    if (isReverse) {
        NSLog(@"NSAttributedStringEnumerationReverse option unimplemented");
    }
    
    BOOL shouldStop = NO;
    NSInteger pos = enumerationRange.location;
    NSInteger end = NSMaxRange(enumerationRange);
    while (pos < end) {
        NSRange effectiveRange;
        id attribute = nil;
        if (isLongestEffectiveRangeNotRequired) {
            attribute = [self attribute:attrName atIndex:pos effectiveRange:&effectiveRange];
        } else {
            attribute = [self attribute:attrName atIndex:pos longestEffectiveRange:&effectiveRange inRange:enumerationRange];
        }
        
        block(attribute,effectiveRange,&shouldStop);
        
        pos = NSMaxRange(effectiveRange);
        if (shouldStop) {
            break;
        }
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
