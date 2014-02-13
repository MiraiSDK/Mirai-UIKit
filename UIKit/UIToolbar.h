//
//  UIToolbar.h
//  UIKit
//
//  Created by Chen Yonghui on 2/13/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIView.h>
#import <UIKit/UIInterface.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIBarButtonItem.h>
#import <UIKit/UIBarCommon.h>

@class UIBarButtonItem, UIColor;
@protocol UIToolbarDelegate;

@interface UIToolbar : UIView <UIBarPositioning>
@property(nonatomic)        UIBarStyle barStyle;
@property(nonatomic,copy)   NSArray   *items;
@property(nonatomic,assign,getter=isTranslucent) BOOL translucent;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@property(nonatomic,retain) UIColor *tintColor;
@property(nonatomic,retain) UIColor *barTintColor;

- (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backgroundImageForToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics;

- (void)setShadowImage:(UIImage *)shadowImage forToolbarPosition:(UIBarPosition)topOrBottom;
- (UIImage *)shadowImageForToolbarPosition:(UIBarPosition)topOrBottom;

@property(nonatomic,assign) id<UIToolbarDelegate> delegate;// NS_AVAILABLE_IOS(7_0);

@end

@protocol UIToolbarDelegate <UIBarPositioningDelegate>
@end
