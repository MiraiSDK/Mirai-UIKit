//
//  UIMenuBubbleView.m
//  UIKit
//
//  Created by TaoZeyu on 15/5/19.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIMenuBubbleView.h"

#define kArrowWidth 5
#define kArrowHeight 26

#define kMinimumMenuItemButtonWidth 100
#define kMaximumMenuItemButtonWidth 500
#define kMenuItemButtonHeight 40

#define kCenterOnBorderScale 0.5

@interface UIMenuBubbleView ()
{
    UIMenuController *_parentMenuController;
}
@end

@implementation UIMenuBubbleView

- (instancetype)initWithParent:(UIMenuController *)parentMenuController
{
    if (self = [super init]) {
        _parentMenuController = parentMenuController;
    }
    return self;
}

- (void)setKeyWindowTargetRect:(CGRect)targetRect
{
    self.floatCloseToTarget = targetRect;
}

- (CGRect)menuFrame
{
    return self.frame;
}

- (void)reciveMaskedTouch:(UITouch *)touch
{
    [_parentMenuController setMenuVisible:NO animated:YES];
}

#pragma mark - menu items

- (void)setMenuItems:(NSArray *)menuItems
{
    [self _clearAllOldMenuItems];
    [self _makeMenuItemButtonsAndAddToSelfWithArray:menuItems];
}

- (void)_clearAllOldMenuItems
{
    while (self.container.subviews.count > 0) {
        UIView *subview = [self.container.subviews objectAtIndex:0];
        [subview removeFromSuperview];
    }
}

- (void)_makeMenuItemButtonsAndAddToSelfWithArray:(NSArray *)menuItems
{
    CGFloat nextButtonXPosition = 0;
    for (NSUInteger i = 0; i < menuItems.count; i++) {
        UIButton *menuItemButton = [self _createButtonWith:[menuItems objectAtIndex:i] at:i];
        menuItemButton.frame = [self _getFrameWithMenuItemButton:menuItemButton
                                              withStartXLocation:nextButtonXPosition];
        nextButtonXPosition += menuItemButton.bounds.size.width;
        [self.container addSubview:menuItemButton];
    }
    self.containerSize = CGSizeMake(nextButtonXPosition, kMenuItemButtonHeight);
}

- (UIButton *)_createButtonWith:(UIMenuItem *)menuItem at:(NSUInteger)index
{
    UIButton *menuItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [menuItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [menuItemButton setTitle:menuItem.title forState:UIControlStateNormal];
    [menuItemButton setBackgroundColor:[UIColor blackColor]];
    menuItemButton.tag = index;
    
    [menuItemButton addTarget:self action:@selector(_onTappedMenuItemButton:)
             forControlEvents:UIControlEventTouchUpInside];
    return menuItemButton;
}

- (CGRect)_getFrameWithMenuItemButton:(UIButton *)menuItemButton withStartXLocation:(CGFloat)x
{
    CGFloat menuItemButtonWidth = [self _getWithWithMenuItemButton:menuItemButton];
    return CGRectMake(x, 0, menuItemButtonWidth, kMenuItemButtonHeight);
}

- (CGFloat)_getWithWithMenuItemButton:(UIButton *)menuItemButton
{
    CGFloat width = menuItemButton.titleLabel.preferredMaxLayoutWidth;
    width = MIN(kMaximumMenuItemButtonWidth, width);
    width = MAX(kMinimumMenuItemButtonWidth, width);
    return width;
}

- (void)_onTappedMenuItemButton:(UIButton *)menuItemButton
{
    NSNumber *index = [NSNumber numberWithUnsignedInteger:menuItemButton.tag];
    [_parentMenuController performSelector:@selector(_onTappedMenuItemWithIndex:) withObject:index];
}

#pragma mark - choose appropriate arrow location and direction.

- (NSArray *)testPositionOnBorderDirectionList
{
    static NSArray *directionList;
    if (!directionList) {
        directionList = @[@(UIPositionOnRectDirectionUp), @(UIPositionOnRectDirectionDown),
                          @(UIPositionOnRectDirectionLeft), @(UIPositionOnRectDirectionRight),
                          @(UIPositionOnRectDirectionNone)];
    }
    return directionList;
}

@end
