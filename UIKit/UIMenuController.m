//
//  UIMenuController.m
//  UIKit
//
//  Created by Chen Yonghui on 11/4/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIMenuController.h"
#import "UIMenuBubbleView.h"
#import "UIWindow+UIPrivate.h"

@interface UIMenuController ()
@property (nonatomic, strong) UIMenuBubbleView *menuBubbleView;
@end

@implementation UIMenuController

+ (UIMenuController *)sharedMenuController
{
    static dispatch_once_t onceToken;
    static UIMenuController *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;

}

- (instancetype)init
{
    if (self = [super init]) {
        _arrowDirection = UIMenuControllerArrowDefault;
        _menuBubbleView = [[UIMenuBubbleView alloc] initWithParent:self];
    }
    return self;
}

- (void)update
{
}

- (CGRect)menuFrame
{
    if (![self isMenuVisible]) {
        return CGRectZero;
    }
    return _menuBubbleView.menuFrame;
}

#pragma mark - menu item events

- (void)_onTappedMenuItemWithIndex:(NSNumber *)index
{
    UIMenuItem *menuItem = [_menuItems objectAtIndex:index.unsignedIntegerValue];
    [[UIApplication sharedApplication] sendAction:menuItem.action to:nil from:self forEvent:nil];
    [self setMenuVisible:NO animated:YES];
}

#pragma mark - menu appearance.

- (void)setMenuItems:(NSArray *)menuItems
{
    _menuItems = menuItems;
    CGRect oldMenuFrame = _menuBubbleView.menuFrame;
    [_menuBubbleView setMenuItems:menuItems];
    
    if (!CGRectEqualToRect(oldMenuFrame, _menuBubbleView.menuFrame)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UIMenuControllerMenuFrameDidChangeNotification object:nil];
    }
}

- (void)setMenuVisible:(BOOL)menuVisible
{
    [self setMenuVisible:menuVisible animated:NO];
}

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (_menuVisible != menuVisible) {
        _menuVisible = menuVisible;
        if (menuVisible) {
            [center postNotificationName:UIMenuControllerWillShowMenuNotification object:nil];
            [self _showMenuBubbleViewOnKeyWindow];
            [center postNotificationName:UIMenuControllerDidShowMenuNotification object:nil];
        } else {
            [center postNotificationName:UIMenuControllerWillHideMenuNotification object:nil];
            [_menuBubbleView removeFromSuperview];
            [center postNotificationName:UIMenuControllerDidHideMenuNotification object:nil];
        }
    }
}

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    _menuBubbleView.keyWindowTargetRect = [targetView convertRect:targetRect toView:keyWindow];
}

- (void)_showMenuBubbleViewOnKeyWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow _addMenuBubbleView:_menuBubbleView];
}

@end

@implementation UIMenuItem

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action
{
    self = [super init];
    if (self) {
        _title = title;
        _action = action;
    }
    return self;
}

@end
NSString *const UIMenuControllerWillShowMenuNotification = @"UIMenuControllerWillShowMenuNotification";
NSString *const UIMenuControllerDidShowMenuNotification = @"UIMenuControllerDidShowMenuNotification";
NSString *const UIMenuControllerWillHideMenuNotification = @"UIMenuControllerWillHideMenuNotification";
NSString *const UIMenuControllerDidHideMenuNotification = @"UIMenuControllerDidHideMenuNotification";
NSString *const UIMenuControllerMenuFrameDidChangeNotification = @"UIMenuControllerMenuFrameDidChangeNotification";
