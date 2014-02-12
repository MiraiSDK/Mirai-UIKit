//
//  UINavigationBar.h
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIView.h>
#import <UIKit/UIInterface.h>
#import <UIKit/UIFont.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIButton.h>
//#import <UIKit/UIBarButtonItem.h>
#import <UIKit/UIBarCommon.h>

@class UINavigationItem, UIBarButtonItem, UIImage, UIColor;
@protocol UINavigationBarDelegate;

@interface UINavigationBar : UIView <NSCoding, UIBarPositioning>
@property(nonatomic,assign) UIBarStyle barStyle;
@property(nonatomic,assign) id delegate;
@property(nonatomic,assign,getter=isTranslucent) BOOL translucent; // Default is NO on iOS 6 and earlier. Always YES if barStyle is set to UIBarStyleBlackTranslucent

- (void)pushNavigationItem:(UINavigationItem *)item animated:(BOOL)animated;
- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated;

@property(nonatomic,readonly,retain) UINavigationItem *topItem;
@property(nonatomic,readonly,retain) UINavigationItem *backItem;

@property(nonatomic,copy) NSArray *items;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;
@property(nonatomic,retain) UIColor *tintColor;
@property(nonatomic,retain) UIColor *barTintColor;// NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;


- (void)setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backgroundImageForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backgroundImageForBarMetrics:(UIBarMetrics)barMetrics;

@property(nonatomic,retain) UIImage *shadowImage;

@property(nonatomic,copy) NSDictionary *titleTextAttributes;

- (void)setTitleVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics;
- (CGFloat)titleVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics;

@property(nonatomic,retain) UIImage *backIndicatorImage;// NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property(nonatomic,retain) UIImage *backIndicatorTransitionMaskImage;// NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;

@end

@protocol UINavigationBarDelegate <UIBarPositioningDelegate>

@optional

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item;
- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item;
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item;
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item;

@end

@interface UINavigationItem : NSObject <NSCoding>
- (id)initWithTitle:(NSString *)title; // Designated initializer

@property(nonatomic,copy)   NSString        *title;
@property(nonatomic,retain) UIBarButtonItem *backBarButtonItem;
@property(nonatomic,retain) UIView          *titleView;

@property(nonatomic,copy)   NSString *prompt;

@property(nonatomic,assign) BOOL hidesBackButton;
- (void)setHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated;

@property(nonatomic,copy) NSArray *leftBarButtonItems;
@property(nonatomic,copy) NSArray *rightBarButtonItems;
- (void)setLeftBarButtonItems:(NSArray *)items animated:(BOOL)animated;
- (void)setRightBarButtonItems:(NSArray *)items animated:(BOOL)animated;

@property(nonatomic) BOOL leftItemsSupplementBackButton;

@property(nonatomic,retain) UIBarButtonItem *leftBarButtonItem;
@property(nonatomic,retain) UIBarButtonItem *rightBarButtonItem;
- (void)setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
- (void)setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;

@end

