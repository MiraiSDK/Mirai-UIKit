//
//  UILocalizedIndexedCollation.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UILocalizedIndexedCollation.h"

@implementation UILocalizedIndexedCollation
+ (id)currentCollation
{
    return nil;
}

- (NSInteger)sectionForSectionIndexTitleAtIndex:(NSInteger)indexTitleIndex
{
    return 0;
}

- (NSInteger)sectionForObject:(id)object collationStringSelector:(SEL)selector
{
    return 0;
}

- (NSArray *)sortedArrayFromArray:(NSArray *)array collationStringSelector:(SEL)selector
{
    return [array copy];
}

@end
