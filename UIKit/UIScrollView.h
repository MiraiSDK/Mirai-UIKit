//
//  UIScrollView.h
//  UIKit
//
//  Created by Chen Yonghui on 2/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIView.h>
#import <UIKit/UIGeometry.h>
#import <UIKit/UIKitDefines.h>

typedef NS_ENUM(NSInteger, UIScrollViewIndicatorStyle) {
    UIScrollViewIndicatorStyleDefault,
    UIScrollViewIndicatorStyleBlack,
    UIScrollViewIndicatorStyleWhite
};

typedef NS_ENUM(NSInteger, UIScrollViewKeyboardDismissMode) {
    UIScrollViewKeyboardDismissModeNone,
    UIScrollViewKeyboardDismissModeOnDrag,
    UIScrollViewKeyboardDismissModeInteractive,
};// NS_ENUM_AVAILABLE_IOS(7_0);

UIKIT_EXTERN const CGFloat UIScrollViewDecelerationRateNormal;
UIKIT_EXTERN const CGFloat UIScrollViewDecelerationRateFast;

@class UIEvent, UIImageView, UIPanGestureRecognizer, UIPinchGestureRecognizer;
@protocol UIScrollViewDelegate;

@interface UIScrollView : UIView <NSCoding>

@property(nonatomic)         CGPoint                      contentOffset;
@property(nonatomic)         CGSize                       contentSize;
@property(nonatomic)         UIEdgeInsets                 contentInset;
@property(nonatomic,weak) id<UIScrollViewDelegate>      delegate;
@property(nonatomic,getter=isDirectionalLockEnabled) BOOL directionalLockEnabled;
@property(nonatomic)         BOOL                         bounces;
@property(nonatomic)         BOOL                         alwaysBounceVertical;
@property(nonatomic)         BOOL                         alwaysBounceHorizontal;
@property(nonatomic,getter=isPagingEnabled) BOOL          pagingEnabled;
@property(nonatomic,getter=isScrollEnabled) BOOL          scrollEnabled;
@property(nonatomic)         BOOL                         showsHorizontalScrollIndicator;
@property(nonatomic)         BOOL                         showsVerticalScrollIndicator;
@property(nonatomic)         UIEdgeInsets                 scrollIndicatorInsets;
@property(nonatomic)         UIScrollViewIndicatorStyle   indicatorStyle;
@property(nonatomic)         CGFloat                      decelerationRate;

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated;

- (void)flashScrollIndicators;

@property(nonatomic,readonly,getter=isTracking)     BOOL tracking;
@property(nonatomic,readonly,getter=isDragging)     BOOL dragging;
@property(nonatomic,readonly,getter=isDecelerating) BOOL decelerating;

@property(nonatomic) BOOL delaysContentTouches;
@property(nonatomic) BOOL canCancelContentTouches;

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view;
- (BOOL)touchesShouldCancelInContentView:(UIView *)view;

@property(nonatomic) CGFloat minimumZoomScale;
@property(nonatomic) CGFloat maximumZoomScale;

@property(nonatomic) CGFloat zoomScale;
- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated;
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;

@property(nonatomic) BOOL  bouncesZoom;

@property(nonatomic,readonly,getter=isZooming)       BOOL zooming;
@property(nonatomic,readonly,getter=isZoomBouncing)  BOOL zoomBouncing;

@property(nonatomic) BOOL  scrollsToTop;

@property(nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, readonly) UIPinchGestureRecognizer *pinchGestureRecognizer;

@property(nonatomic) UIScrollViewKeyboardDismissMode keyboardDismissMode;// NS_AVAILABLE_IOS(7_0);

@end

@protocol UIScrollViewDelegate<NSObject>

@optional

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidZoom:(UIScrollView *)scrollView;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view;
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale;

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;

@end
