//
//  UISegmentedControl.h
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIControl.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIGeometry.h>
#import <UIKit/UIBarButtonItem.h>

typedef NS_ENUM(NSInteger, UISegmentedControlStyle) {
    UISegmentedControlStylePlain,     // large plain
    UISegmentedControlStyleBordered,  // large bordered
    UISegmentedControlStyleBar,       // small button/nav bar style. tintable
    UISegmentedControlStyleBezeled,   // DEPRECATED. Do not use this style.
};

enum {
    UISegmentedControlNoSegment = -1   // segment index for no selected segment
};

typedef NS_ENUM(NSInteger, UISegmentedControlSegment) {
    UISegmentedControlSegmentAny = 0,
    UISegmentedControlSegmentLeft = 1,   // The capped, leftmost segment. Only applies when numSegments > 1.
    UISegmentedControlSegmentCenter = 2, // Any segment between the left and rightmost segments. Only applies when numSegments > 2.
    UISegmentedControlSegmentRight = 3,  // The capped,rightmost segment. Only applies when numSegments > 1.
    UISegmentedControlSegmentAlone = 4,  // The standalone segment, capped on both ends. Only applies when numSegments = 1.
};

@class UIImage, UIColor;

@interface UISegmentedControl : UIControl <NSCoding>
- (instancetype)initWithItems:(NSArray *)items;

@property(nonatomic) UISegmentedControlStyle segmentedControlStyle; //NS_DEPRECATED_IOS(2_0, 7_0, "The segmentedControlStyle property no longer has any effect");
@property(nonatomic,getter=isMomentary) BOOL momentary;
@property(nonatomic,readonly) NSUInteger numberOfSegments;

@property(nonatomic) BOOL apportionsSegmentWidthsByContent;

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)insertSegmentWithImage:(UIImage *)image  atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)removeAllSegments;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment;

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment;
- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment;

- (void)setContentOffset:(CGSize)offset forSegmentAtIndex:(NSUInteger)segment;
- (CGSize)contentOffsetForSegmentAtIndex:(NSUInteger)segment;

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment;
- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment;

@property(nonatomic) NSInteger selectedSegmentIndex;

@property(nonatomic,retain) UIColor *tintColor;

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

- (void)setDividerImage:(UIImage *)dividerImage forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)dividerImageForLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState barMetrics:(UIBarMetrics)barMetrics;

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state;
- (NSDictionary *)titleTextAttributesForState:(UIControlState)state;

- (void)setContentPositionAdjustment:(UIOffset)adjustment forSegmentType:(UISegmentedControlSegment)leftCenterRightOrAlone barMetrics:(UIBarMetrics)barMetrics;
- (UIOffset)contentPositionAdjustmentForSegmentType:(UISegmentedControlSegment)leftCenterRightOrAlone barMetrics:(UIBarMetrics)barMetrics;

@end
