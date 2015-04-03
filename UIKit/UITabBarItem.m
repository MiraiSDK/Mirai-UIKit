//
//  UITabBarItem.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITabBarItem.h"
#import "UIImage.h"

@interface UITabBarItem()
@end

static NSArray *systemItemImageNameArray;
static NSArray *systemItemTitleArray;

@implementation UITabBarItem

+ (void)initialize
{
    [self initializeSystemItemResources];
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag
{
    self = [super init];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage
{
    self = [super init];
    return self;
}

- (instancetype)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem tag:(NSInteger)tag
{
    NSString *title = [self.class _findImageTitleWithSystemItem:systemItem];
    UIImage *image = [self.class _findImageWithSystemItem:systemItem];
    return [self initWithTitle:title image:image tag:tag];
}

- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage
{
    
}

- (UIImage *)finishedSelectedImage
{
    return nil;
}

- (UIImage *)finishedUnselectedImage
{
    return nil;
}

- (void)setTitlePositionAdjustment:(UIOffset)adjustment
{
    
}

- (UIOffset)titlePositionAdjustment
{
    return UIOffsetZero;
}

#pragma mark - system items.

+ (void)initializeSystemItemResources
{
    // I have't prepared any images for UITabBarSystemItem icons.
    systemItemImageNameArray = @[
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 @"tabicon0.png",
                                 ];
    systemItemTitleArray = @[
                             @"more",
                             @"favorites",
                             @"featured",
                             @"topRated",
                             @"recents",
                             @"contacts",
                             @"history",
                             @"bookmarks",
                             @"search",
                             @"downloads",
                             @"most recent",
                             @"most viewed",
                             ];
}

+ (UIImage *)_findImageWithSystemItem:(UITabBarSystemItem)systemItem
{
    NSString *imageName = [systemItemImageNameArray objectAtIndex:(NSUInteger)systemItem];
    return [UIImage imageNamed:imageName];
}

+ (NSString *)_findImageTitleWithSystemItem:(UITabBarSystemItem)systemItem
{
    return [systemItemTitleArray objectAtIndex:(NSUInteger)systemItem];
}

@end
