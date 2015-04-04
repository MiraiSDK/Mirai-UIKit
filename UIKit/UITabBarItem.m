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
@property (nonatomic, strong) id displayRefreshCallbackTarget;
@property (nonatomic) SEL displayRefreshCallbackAction;
@end

static NSArray *systemItemImageNameArray;
static NSArray *systemItemTitleArray;

@implementation UITabBarItem

#pragma mark - initialize.

+ (void)initialize
{
    [self _initializeSystemItemImageNames];
    [self _initializeSystemItemTitiles];
}

- (instancetype)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem tag:(NSInteger)tag
{
    NSString *title = [self.class _findImageTitleWithSystemItem:systemItem];
    UIImage *image = [self.class _findImageWithSystemItem:systemItem];
    return [self initWithTitle:title image:image tag:tag];
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag
{
    self = [self initWithTitle:title image:image selectedImage:image];
    if (self) {
        self.tag = tag;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage
{
    self = [super init];
    if (self) {
        self.image = image;
        self.selectedImage = selectedImage;
    }
    return self;
}

- (void)setCallbackWhenNeedRefreshDisplayWithTarget:(id)target action:(SEL)action
{
    self.displayRefreshCallbackTarget = target;
    self.displayRefreshCallbackAction = action;
}

- (void)clearCallbackWhenNeedRefreshDisplay
{
    self.displayRefreshCallbackTarget = nil;
    self.displayRefreshCallbackAction = NULL;
}

#pragma mark - setting images.

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    [self _needRefreshDisplay];
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    _selectedImage = selectedImage;
    [self _needRefreshDisplay];
}

- (void)setTitlePositionAdjustment:(UIOffset)adjustment
{
    _titlePositionAdjustment = adjustment;
    [self _needRefreshDisplay];
}

- (void)_needRefreshDisplay
{
    if (self.displayRefreshCallbackTarget) {
        [self.displayRefreshCallbackTarget performSelector:self.displayRefreshCallbackAction withObject:self];
    }
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

#pragma mark - system items.

+ (void)_initializeSystemItemImageNames
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
                                 ];}

+ (void)_initializeSystemItemTitiles
{
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
