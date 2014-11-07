//
//  UILocalizedIndexedCollation.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

@interface UILocalizedIndexedCollation : NSObject
+ (id)currentCollation;

@property(nonatomic, readonly) NSArray *sectionTitles;
@property(nonatomic, readonly) NSArray *sectionIndexTitles;

- (NSInteger)sectionForSectionIndexTitleAtIndex:(NSInteger)indexTitleIndex;
- (NSInteger)sectionForObject:(id)object collationStringSelector:(SEL)selector;
- (NSArray *)sortedArrayFromArray:(NSArray *)array collationStringSelector:(SEL)selector;

@end
