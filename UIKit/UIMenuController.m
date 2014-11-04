//
//  UIMenuController.m
//  UIKit
//
//  Created by Chen Yonghui on 11/4/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIMenuController.h"

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

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated
{
    
}

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView
{
    
}

- (void)update
{
    
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
