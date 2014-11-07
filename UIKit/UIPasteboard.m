//
//  UIPasteboard.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPasteboard.h"

NSString *const UIPasteboardNameGeneral = @"UIPasteboardNameGeneral";
NSString *const UIPasteboardNameFind = @"UIPasteboardNameFind";

@interface UIPasteboard ()
@property(nonatomic,copy) NSString *string;
@property(nonatomic,copy) NSArray *strings;

@property(nonatomic,copy) NSURL *URL;
@property(nonatomic,copy) NSArray *URLs;

@property(nonatomic,copy) UIImage *image;
@property(nonatomic,copy) NSArray *images;

@property(nonatomic,copy) UIColor *color;
@property(nonatomic,copy) NSArray *colors;
@end

@implementation UIPasteboard
+ (UIPasteboard *)generalPasteboard
{
    return nil;
}

+ (UIPasteboard *)pasteboardWithName:(NSString *)pasteboardName create:(BOOL)create
{
    return nil;
}

+ (UIPasteboard *)pasteboardWithUniqueName
{
    return nil;
}

+ (void)removePasteboardWithName:(NSString *)pasteboardName
{
    
}

// First item

- (NSArray *)pasteboardTypes
{
    return @[];
}

- (BOOL)containsPasteboardTypes:(NSArray *)pasteboardTypes
{
    return NO;
}

- (NSData *)dataForPasteboardType:(NSString *)pasteboardType
{
    return nil;
}

- (id)valueForPasteboardType:(NSString *)pasteboardType
{
    return nil;
}

- (void)setValue:(id)value forPasteboardType:(NSString *)pasteboardType
{
    
}

- (void)setData:(NSData *)data forPasteboardType:(NSString *)pasteboardType
{
    
}

#pragma - Multiple items
- (NSArray *)pasteboardTypesForItemSet:(NSIndexSet*)itemSet
{
    return @[];
}

- (BOOL)containsPasteboardTypes:(NSArray *)pasteboardTypes inItemSet:(NSIndexSet *)itemSet
{
    return NO;
}

- (NSIndexSet *)itemSetWithPasteboardTypes:(NSArray *)pasteboardTypes
{
    return nil;
}

- (NSArray *)valuesForPasteboardType:(NSString *)pasteboardType inItemSet:(NSIndexSet *)itemSet
{
    return @[];
}

- (NSArray *)dataForPasteboardType:(NSString *)pasteboardType inItemSet:(NSIndexSet *)itemSet
{
    return @[];
}

#pragma - Direct access

- (void)addItems:(NSArray *)items
{
    
}

@end

// Notification

NSString *const UIPasteboardChangedNotification = @"";
NSString *const    UIPasteboardChangedTypesAddedKey = @"";
NSString *const    UIPasteboardChangedTypesRemovedKey = @"";

NSString *const UIPasteboardRemovedNotification = @"";

// Extensions

NSArray *UIPasteboardTypeListString;
NSArray *UIPasteboardTypeListURL;
NSArray *UIPasteboardTypeListImage;
NSArray *UIPasteboardTypeListColor;


