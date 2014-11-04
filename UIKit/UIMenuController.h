//
//  UIMenuController.h
//  UIKit
//
//  Created by Chen Yonghui on 11/4/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKitDefines.h>

typedef NS_ENUM(NSInteger, UIMenuControllerArrowDirection) {
    UIMenuControllerArrowDefault, // up or down based on screen location
#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    UIMenuControllerArrowUp,
    UIMenuControllerArrowDown,
    UIMenuControllerArrowLeft,
    UIMenuControllerArrowRight,
#endif
};

@class UIView;

@interface UIMenuController : NSObject

+ (UIMenuController *)sharedMenuController;

@property(nonatomic,getter=isMenuVisible) BOOL menuVisible;
- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated;

- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView;
@property(nonatomic) UIMenuControllerArrowDirection arrowDirection;

@property(nonatomic,copy) NSArray *menuItems;

- (void)update;

@property(nonatomic,readonly) CGRect menuFrame;

@end

UIKIT_EXTERN NSString *const UIMenuControllerWillShowMenuNotification;
UIKIT_EXTERN NSString *const UIMenuControllerDidShowMenuNotification;
UIKIT_EXTERN NSString *const UIMenuControllerWillHideMenuNotification;
UIKIT_EXTERN NSString *const UIMenuControllerDidHideMenuNotification;
UIKIT_EXTERN NSString *const UIMenuControllerMenuFrameDidChangeNotification;

@interface UIMenuItem : NSObject

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action;

@property(nonatomic,copy) NSString *title;     // default is nil
@property(nonatomic)      SEL       action;    // default is NULL

@end
