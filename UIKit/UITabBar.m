//
//  UITabBar.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIImage.h"
#import "UIImageView.h"
#import "UITabBar.h"
#import "UITabBarItem.h"
#import "UILabel.h"
#import "UIView.h"

#define NilIndex NSUIntegerMax
#define ItemTitleHeight 35

@interface UITabBar()
@property NSUInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray *itemImageBuffered;
@property (nonatomic, strong) NSMutableArray *itemTitleBuffered;
@end

@implementation UITabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initDefaultValues];
    }
    return self;
}

- (void)_initDefaultValues
{
    self.selectedIndex = NilIndex;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self _refreshItemsAppearanceAndLocation];
}

- (UITabBarItem *)selectedItem
{
    if (self.selectedIndex == NilIndex) {
        return nil;
    }
    return (UITabBarItem *)[self.items objectAtIndex:self.selectedIndex];
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem
{
    NSUInteger index = [self _findIndexWithItem:selectedItem];
    if (index == self.selectedIndex) {
        self.selectedIndex = index;
        [self _refreshItemsAppearanceAndLocation];
    }
}

- (NSUInteger)_findIndexWithItem:(UITabBarItem *)choosedItem
{
    for (NSUInteger i = 0; i < [self.items count]; i++) {
        UITabBarItem *item = [self.items objectAtIndex:i];
        if (item == choosedItem) {
            return i;
        }
    }
    return NilIndex;
}

- (void)setItems:(NSArray *)items
{
    [self setItems:items animated:NO];
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    _items = items;
    [self _removeAllSubviewFrom:self.itemImageBuffered];
    [self _removeAllSubviewFrom:self.itemTitleBuffered];
    [self _makeItemImageBufferedWithItems:items];
    [self _makeItemTitleBufferedWithItems:items];
    [self _refreshItemsAppearanceAndLocation];
}

- (void)_clearCallbackForAllItems
{
    for (NSUInteger i = 0; i < [self.items count]; i++) {
        UITabBarItem *item = [self.items objectAtIndex:i];
        [item clearCallbackWhenNeedRefreshDisplay];
    }
}

- (void)_addCallbackForAllItems
{
    for (NSUInteger i = 0; i < [self.items count]; i++) {
        UITabBarItem *item = [self.items objectAtIndex:i];
        [item setCallbackWhenNeedRefreshDisplayWithTarget:self
                                                   action:@selector(_refreshAppearanceForItem:)];
    }
}

- (void)_removeAllSubviewFrom:(NSArray *)array
{
    if (array == nil) {
        return;
    }
    for (NSUInteger i = 0; i < [array count]; i++) {
        UIView *subview = [array objectAtIndex:i];
        [subview removeFromSuperview];
    }
}

- (void)_makeItemImageBufferedWithItems:(NSArray *)items
{
    self.itemImageBuffered = [self _createArrayWith:items andGenerateElementWith:^UIView *(UITabBarItem *item) {
        UIImage *image;
        if (self.selectedItem == item) {
            image = item.selectedImage;
        } else {
            image = item.image;
        }
        return [[UIImageView alloc] initWithImage:image];
    }];
}

- (void)_makeItemTitleBufferedWithItems:(NSArray *)items
{
    self.itemTitleBuffered = [self _createArrayWith:items andGenerateElementWith:^UIView *(UITabBarItem *item) {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
        [title setText:item.title];
        return title;
    }];
}

- (NSMutableArray *)_createArrayWith:(NSArray *)sourceArray andGenerateElementWith:(UIView *(^)(UITabBarItem *item))handler
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [sourceArray count]; i++) {
        UITabBarItem *item = [sourceArray objectAtIndex:i];
        UIView *result = handler(item);
        [results insertObject:result atIndex:i];
        [self addSubview:result];
    }
    return results;
}

- (void)_refreshItemsAppearanceAndLocation
{
    for (NSUInteger i = 0; i < self.items.count; i++) {
        CGRect cellFrame = [self _createCellFrameForIndex:i];
        UITabBarItem *item = [self.items objectAtIndex:i];
        [self _setAppearanceOfItem:item withFrame:cellFrame at:i];
    }
}

- (void)_refreshAppearanceForItem:(UITabBarItem *)item
{
    NSUInteger index = [self _findIndexWithItem:item];
    CGRect cellFrame = [self _createCellFrameForIndex:index];
    [self _setAppearanceOfItem:item withFrame:cellFrame at:index];
}

- (CGRect)_createCellFrameForIndex:(NSUInteger)index
{
    CGFloat cellWidth = self.frame.size.width/self.items.count;
    return CGRectMake(index*cellWidth, 0, cellWidth, self.frame.size.height);
}

- (void)_setAppearanceOfItem:(UITabBarItem *)item withFrame:(CGRect)frame at:(NSUInteger)index
{
    // make the UILabel on the bottom of frame, and the UIImageView on the center of the rest of area.
    UIImageView *imageView = [self _getItemImageAt:index];
    UILabel *title = [self _getItemTitleAt:index];
    
    CGFloat titleTopLine = frame.origin.y + frame.size.height - ItemTitleHeight;
    title.frame = CGRectMake(frame.origin.x, titleTopLine, frame.size.width, ItemTitleHeight);
    
    CGFloat gapWidth = (frame.size.width - imageView.image.size.width)/2;
    CGFloat gapHeight = (frame.size.height - ItemTitleHeight - imageView.image.size.height)/2;
    
    imageView.frame = CGRectMake(frame.origin.x + gapWidth, frame.origin.y + gapHeight,
                                 imageView.image.size.width, imageView.image.size.height);
}

#pragma mark - items operation.

- (UITabBarItem *)_getItemAt:(NSUInteger)index
{
    return (UITabBarItem *)[self.items objectAtIndex:index];
}

- (UIImageView *)_getItemImageAt:(NSUInteger)index
{
    return (UIImageView *)[self.itemImageBuffered objectAtIndex:index];
}

- (UILabel *)_getItemTitleAt:(NSUInteger)index
{
    return (UILabel *)[self.itemTitleBuffered objectAtIndex:index];
}

- (void)_replaceItemImage:(UIImage *)image at:(NSUInteger)index
{
    [[self _getItemImageAt:index] removeFromSuperview];
    
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:image];
    [self.itemImageBuffered replaceObjectAtIndex:index withObject:newImageView];
    [self addSubview:newImageView];
}

@end
