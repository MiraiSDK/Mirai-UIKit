//
//  UIScrollView.m
//  UIKit
//
//  Created by Chen Yonghui on 2/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIScrollView.h"
#import "UIScroller.h"

static const NSTimeInterval UIScrollViewAnimationDuration = 0.33;
static const NSTimeInterval UIScrollViewQuickAnimationDuration = 0.22;
static const NSUInteger UIScrollViewScrollAnimationFramesPerSecond = 60;

const float UIScrollViewDecelerationRateNormal = 0.998;
const float UIScrollViewDecelerationRateFast = 0.99;

@interface UIScrollView () <_UIScrollerDelegate>

@end

@implementation UIScrollView {
    UIScroller *_verticalScroller;
    UIScroller *_horizontalScroller;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentOffset = CGPointZero;
        _contentSize = CGSizeZero;
        _contentInset = UIEdgeInsetsZero;
        _scrollIndicatorInsets = UIEdgeInsetsZero;
        _showsVerticalScrollIndicator = YES;
        _showsHorizontalScrollIndicator = YES;
        _maximumZoomScale = 1;
        _minimumZoomScale = 1;
        _scrollsToTop = YES;
        _indicatorStyle = UIScrollViewIndicatorStyleDefault;
        _delaysContentTouches = YES;
        _canCancelContentTouches = YES;
        _pagingEnabled = NO;
        _bouncesZoom = NO;
        _zooming = NO;
        _alwaysBounceVertical = NO;
        _alwaysBounceHorizontal = NO;
        _bounces = YES;
//        _decelerationRate = UIScrollViewDecelerationRateNormal;
        
//        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureDidChange:)];
//        [self addGestureRecognizer:_panGestureRecognizer];
        
//        _scrollWheelGestureRecognizer = [[UIScrollWheelGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureDidChange:)];
//        [self addGestureRecognizer:_scrollWheelGestureRecognizer];
        
        _verticalScroller = [[UIScroller alloc] init];
        _verticalScroller.delegate = self;
        [self addSubview:_verticalScroller];
        
        _horizontalScroller = [[UIScroller alloc] init];
        _horizontalScroller.delegate = self;
        [self addSubview:_horizontalScroller];
        
        self.clipsToBounds = YES;

    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; frame = (%.0f %.0f; %.0f %.0f); clipsToBounds = %@; layer = %@; contentOffset = {%.0f, %.0f}>", [self className], self, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height, (self.clipsToBounds ? @"YES" : @"NO"), self.layer, self.contentOffset.x, self.contentOffset.y];
}


@end
