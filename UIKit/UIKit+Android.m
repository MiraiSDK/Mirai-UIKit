//
//  UIKit+Android.m
//  NextBook
//
//  Created by Chen Yonghui on 4/1/14.
//  Copyright (c) 2014 Shanghai TinyNetwork. All rights reserved.
//

#import "UIKit+Android.h"

#import <CoreFoundation/CoreFoundation.h>

@implementation NSArray (Indexing)
- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self objectAtIndex:idx];
}
@end
@implementation NSMutableArray (Indexing)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    [self replaceObjectAtIndex:idx withObject:obj];
}
@end

// NSMutableDictionary+Indexing.m
@implementation  NSDictionary (Indexing)

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}
@end
@implementation  NSMutableDictionary (Indexing)
- (void)setObject:(id)obj forKeyedSubscript:(id)key
{
    [self setObject:obj forKey:key];
}
@end

@implementation NSString (Android)

- (void)enumerateSubstringsInRange:(NSRange)range options:(NSStringEnumerationOptions)opts usingBlock:(void (^)(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop))block
{
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
}

@end
@implementation NSFileManager (Android)
- (BOOL)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)error
{
    
    return [self createDirectoryAtPath:[url path] withIntermediateDirectories:createIntermediates attributes:attributes error:error];
}

- (NSArray *)URLsForDirectory:(NSSearchPathDirectory)directory inDomains:(NSSearchPathDomainMask)domainMask
{
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [bundlePath stringByDeletingLastPathComponent];
    NSString *result = nil;
    switch (directory) {
        case NSCachesDirectory:
            result = [path stringByAppendingPathComponent:@"Caches"];
            break;
        case NSDocumentDirectory:
            result = [path stringByAppendingPathComponent:@"Document"];
            break;
        case NSLibraryDirectory:
            result = [path stringByAppendingPathComponent:@"Library"];
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
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
}

- (void)enumerateAttribute:(NSString *)attrName inRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id, NSRange, BOOL *))block
{
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
}

@end

@implementation NSArray (Android)


- (NSArray *)sortedArrayUsingComparator:(NSComparator)cmptr
{
    NSLog(@"%s unimplemented",__PRETTY_FUNCTION__);
    return self;
}

- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr
{
    NSLog(@"%s unimplemented",__PRETTY_FUNCTION__);
    return self;
}

- (NSUInteger)indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp
{
    NSLog(@"%s unimplemented",__PRETTY_FUNCTION__);
    return NSNotFound;
}

@end

@implementation NSDictionary (Android)
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [self enumerateKeysAndObjectsWithOptions:0 usingBlock:block];
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    if (opts & NSEnumerationConcurrent) {
        NSLog(@"enumerate with concurrent option is unimplemented");
    }
    
    NSArray *keys = [self allKeys];
    if (opts & NSEnumerationReverse) {
        keys = [keys reverseObjectEnumerator].allObjects;
    }
    BOOL shouldStop = NO;
    for (NSString *key in keys) {
        block(key,self[key],&shouldStop);
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
    NSLog(@"%s",__PRETTY_FUNCTION__);
    for (void (^b)(void) in _blocks) {
        if (self.isCancelled) {
            NSLog(@"block operation cancelled");
            break;
        }
        
        NSLog(@"invoke block");
        b();
    }
}

@end

@implementation NSOperationQueue (Android)

- (void)addOperationWithBlock:(void (^)(void))block
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSBlockOperation *blockOP = [NSBlockOperation blockOperationWithBlock:block];
    [self addOperation:blockOP];
}

@end

@implementation NSSortDescriptor (Android)

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending
{
    return [[self alloc] initWithKey:key ascending:ascending];
}

@end

@implementation NSURL (Android)

+ (id)fileURLWithPath:(NSString *)path isDirectory:(BOOL) isDir
{
    return [NSURL fileURLWithPath:path];
}

@end

@implementation NSIndexSet (Android)
- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger idx, BOOL *stop))block
{
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
}

- (NSIndexSet *)indexesInRange:(NSRange)range options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate
{
    NSLog(@"%s UNIMPLEMENTED",__PRETTY_FUNCTION__);
    return nil;
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
