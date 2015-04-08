//
//  UITabBar.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITabBar.h"
#import "UITabBarItem+UIPrivate.h"
#import "UIImage.h"
#import "UIColor.h"
#import "UIStringDrawing.h"
#import "UIImageView.h"
#import "UITabBarItem.h"
#import "UILabel.h"
#import "UIView.h"

#define ItemTitleHeight 35

#define NormalTitleColor [UIColor blackColor]
#define SelectedTitleColor [UIColor blueColor]
#define DefaultBackgroundColor [UIColor grayColor]

@interface UITabBar()
@property NSUInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray *itemTouchAreaBuffered;
@property (nonatomic, strong) NSMutableArray *itemImageBuffered;
@property (nonatomic, strong) NSMutableArray *itemTitleBuffered;
@end

@implementation UITabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initDefaultValues];
        self.backgroundColor = DefaultBackgroundColor;
    }
    return self;
}

- (void)_initDefaultValues
{
    self.selectedIndex = NSNotFound;
}

#pragma mark - properties operation.

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self _refreshItemsAppearanceAndLocation];
}

- (UITabBarItem *)selectedItem
{
    if (self.selectedIndex == NSNotFound) {
        return nil;
    }
    return (UITabBarItem *)[self.items objectAtIndex:self.selectedIndex];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [self _refreshItemsAppearanceAndLocation];
        [self.delegate tabBar:self didSelectItem:[self selectedItem]];
    }
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem
{
    NSUInteger index = [self _findIndexOfItem:selectedItem];
    if (index == self.selectedIndex) {
        self.selectedIndex = index;
        [self _refreshItemsAppearanceAndLocation];
    }
}

#pragma mark - subviews management.

- (void)setItems:(NSArray *)items
{
    [self setItems:items animated:NO];
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    [self _clearOldAndAddNewCallbackAndReplaceItems:items];
    [self _removeAllSubviewFrom:self.itemTouchAreaBuffered];
    [self _makeAllSubviewForEachItems:items];
    [self _refreshItemsAppearanceAndLocation];
}

- (void)_clearOldAndAddNewCallbackAndReplaceItems:(NSArray *)items
{
    if (self.items != nil) {
        [self _clearCallbackForAllItems];
    }
    _items = [[NSArray alloc] initWithArray:items];
    [self _addCallbackForAllItems];
}

- (void)_makeAllSubviewForEachItems:(NSArray *)items
{
    [self _makeItemTouchAreaWithItems:items];
    [self _makeItemImageBufferedWithItems:items];
    [self _makeItemTitleBufferedWithItems:items];
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
        UIControl *subview = [array objectAtIndex:i];
        [subview removeFromSuperview];
    }
}

- (void)_makeItemTouchAreaWithItems:(NSArray *)items
{
    self.itemTouchAreaBuffered = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [items count]; i++) {
        UIControl *touchArea = [[UIControl alloc] initWithFrame:CGRectZero];
        [self.itemTouchAreaBuffered insertObject:touchArea atIndex:i];
        [self addSubview:touchArea];
        
        [touchArea addTarget:self
                      action:@selector(_onClickTouchArea:)
            forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)_onClickTouchArea:(id)sender
{
    self.selectedIndex = [self _findIndexOfTouchArea:(UIControl *)sender];
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
        title.textAlignment = UITextAlignmentCenter;
        [title setText:item.title];
        title.backgroundColor = [UIColor clearColor];
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
        UIControl *touchArea = [self _getTouchAreaAt:i];
        [touchArea addSubview:result];
    }
    return results;
}

#pragma mark - appearance.

- (void)_refreshItemsAppearanceAndLocation
{
    for (NSUInteger i = 0; i < self.items.count; i++) {
        [self _setTouchAreaApperanceAt:i];
        [self _setSubviewAppearanceAt:i];
    }
}

- (void)_setTouchAreaApperanceAt:(NSUInteger)index
{
    UIControl *touchArea = [self _getTouchAreaAt:index];
    touchArea.frame = [self _createCellFrameForIndex:index];
}

- (void)_refreshAppearanceForItem:(UITabBarItem *)item
{
    NSUInteger index = [self _findIndexOfItem:item];
    [self _setSubviewAppearanceAt:index];
}

- (CGRect)_createCellFrameForIndex:(NSUInteger)index
{
    CGFloat cellWidth = self.frame.size.width/self.items.count;
    return CGRectMake(index*cellWidth, 0, cellWidth, self.frame.size.height);
}

- (void)_setSubviewAppearanceAt:(NSUInteger)index
{
    UITabBarItem *item = [self _getItemAt:index];
    [self _checkIsSelectedAndSetAppearanceWithItem:item at:index];
    
    UIImageView *imageView = [self _getItemImageAt:index];
    [self _setSizeAndLocationWithImage:imageView withItem:item at:index];
}

- (void)_setSizeAndLocationWithImage:(UIImageView *)imageView withItem:(UITabBarItem *)item at:(NSUInteger)index
{
    // make the UILabel on the bottom of frame, and the UIImageView on the center of the rest of area.
    CGRect frame = [self _getTouchAreaAt:index].frame;
    CGFloat titleTopLine = frame.size.height - ItemTitleHeight;
    UILabel *title = [self _getItemTitleAt:index];
    title.frame = CGRectMake(0, titleTopLine, frame.size.width, ItemTitleHeight);
    
    CGFloat gapWidth = (frame.size.width - imageView.image.size.width)/2;
    CGFloat gapHeight = (titleTopLine - imageView.image.size.height)/2;
    
    imageView.frame = CGRectMake(gapWidth + item.titlePositionAdjustment.horizontal,
                                 gapHeight + item.titlePositionAdjustment.vertical,
                                 imageView.image.size.width, imageView.image.size.height);
}

- (void)_checkIsSelectedAndSetAppearanceWithItem:(UITabBarItem *)item at:(NSUInteger)index
{
    [self _setProperAppearanceForItem:item at:index];
    [self _setProperColorForTitleWithItem:item at:index];
}

- (void)_setProperAppearanceForItem:(UITabBarItem *)item at:(NSUInteger)index
{
    UIImage *properImage = [self _getProperImageFromItem:item at:index];
    [self _checkImageEqualsAndReplaceIfNotWith:properImage at:index];
}

- (void)_setProperColorForTitleWithItem:(UITabBarItem *)item at:(NSUInteger)index
{
    UILabel *title = [self _getItemTitleAt:index];
    if ([self _isSelectedAt:index]) {
        [title setTextColor:SelectedTitleColor];
    } else {
        [title setTextColor:NormalTitleColor];
    }
}

- (UIImage *)_getProperImageFromItem:(UITabBarItem *)item at:(NSUInteger)index
{
    if ([self _isSelectedAt:index]) {
        return item.selectedImage;
    } else {
        return item.image;
    }
}

- (void)_checkImageEqualsAndReplaceIfNotWith:(UIImage *)checktedImage at:(NSUInteger)index
{
    UIImageView *imageView = [self _getItemImageAt:index];
    if (imageView.image != checktedImage) {
        [self _replaceItemImage:checktedImage at:index];
    }
}

#pragma mark - items operation.

- (NSUInteger)_findIndexOfItem:(UITabBarItem *)choosedItem
{
    return [self _findIndexOfObject:choosedItem from:self.items];
}

- (NSUInteger)_findIndexOfTouchArea:(UIControl *)touchArea
{
    return [self _findIndexOfObject:touchArea from:self.itemTouchAreaBuffered];
}

- (UIControl *)_getTouchAreaAt:(NSUInteger)index
{
    return (UIControl *)[self.itemTouchAreaBuffered objectAtIndex:index];
}

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
    [[self _getTouchAreaAt:index] addSubview:newImageView];
}

- (BOOL)_isSelectedAt:(NSUInteger)index
{
    return self.selectedIndex == index;
}

- (NSUInteger)_findIndexOfObject:(id)object from:(NSArray *)array
{
    for (NSUInteger i = 0; i < array.count; i++) {
        if ([array objectAtIndex:i] == object) {
            return i;
        }
    }
    return NSNotFound;
}

@end
