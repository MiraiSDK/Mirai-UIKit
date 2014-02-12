//
//  UIBarButtonItem.h
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIBarItem.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIAppearance.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIBarCommon.h>

typedef NS_ENUM(NSInteger, UIBarButtonItemStyle) {
    UIBarButtonItemStylePlain,    // shows glow when pressed
    UIBarButtonItemStyleBordered,
    UIBarButtonItemStyleDone,
};

typedef NS_ENUM(NSInteger, UIBarButtonSystemItem) {
    UIBarButtonSystemItemDone,
    UIBarButtonSystemItemCancel,
    UIBarButtonSystemItemEdit,
    UIBarButtonSystemItemSave,
    UIBarButtonSystemItemAdd,
    UIBarButtonSystemItemFlexibleSpace,
    UIBarButtonSystemItemFixedSpace,
    UIBarButtonSystemItemCompose,
    UIBarButtonSystemItemReply,
    UIBarButtonSystemItemAction,
    UIBarButtonSystemItemOrganize,
    UIBarButtonSystemItemBookmarks,
    UIBarButtonSystemItemSearch,
    UIBarButtonSystemItemRefresh,
    UIBarButtonSystemItemStop,
    UIBarButtonSystemItemCamera,
    UIBarButtonSystemItemTrash,
    UIBarButtonSystemItemPlay,
    UIBarButtonSystemItemPause,
    UIBarButtonSystemItemRewind,
    UIBarButtonSystemItemFastForward,
#if __IPHONE_3_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    UIBarButtonSystemItemUndo,
    UIBarButtonSystemItemRedo,
#endif
#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    UIBarButtonSystemItemPageCurl,
#endif
};

@class UIImage, UIView;

@interface UIBarButtonItem : UIBarItem <NSCoding>
- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
- (id)initWithImage:(UIImage *)image landscapeImagePhone:(UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action;
- (id)initWithCustomView:(UIView *)customView;

@property(nonatomic)         UIBarButtonItemStyle style;
@property(nonatomic)         CGFloat              width;
@property(nonatomic,copy)    NSSet               *possibleTitles;
@property(nonatomic,retain)  UIView              *customView;
@property(nonatomic)         SEL                  action;
@property(nonatomic,assign)  id                   target;

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backgroundImageForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;

@property(nonatomic,retain) UIColor *tintColor;

- (void)setBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics;
- (CGFloat)backgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics;

- (void)setTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics;
- (UIOffset)titlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics;

- (void)setBackButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backButtonBackgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

- (void)setBackButtonTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics;
- (UIOffset)backButtonTitlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics;

- (void)setBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics;
- (CGFloat)backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics;

@end
