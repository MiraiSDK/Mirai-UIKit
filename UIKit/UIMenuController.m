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
    // to see the document, I don't understand this method now.
}

#pragma mark - menu appearance.

- (void)setMenuItems:(NSArray *)menuItems
{
    NSLog(@"%s", __FUNCTION__);
    [_menuBubbleView setMenuItems:menuItems];
}

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated
{
    NSLog(@"%s", __FUNCTION__);
    if (_menuVisible != menuVisible) {
        _menuVisible = menuVisible;
        if (menuVisible) {
            [self _showMenuBubbleViewOnKeyWindow];
        } else {
            [_menuBubbleView removeFromSuperview];
        }
    }
}

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView
{
    NSLog(@"%s", __FUNCTION__);
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
