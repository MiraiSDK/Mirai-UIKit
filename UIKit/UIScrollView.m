/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIScrollView.h"
#import "UIView+UIPrivate.h"
#import "UIScroller.h"
//#import "UIScreen+UIPrivate.h"
#import "UIWindow.h"
#import "UITouch.h"
#import "UIEvent.h"
#import "TNScreenHelper.h"
#import "UIImageView.h"
#import "UIImage+UIPrivate.h"
//#import "UIResponderAppKitIntegration.h"
#import "UIScrollViewAnimationScroll.h"
#import "UIScrollViewAnimationDeceleration.h"
#import "UIPanGestureRecognizer.h"
#import "TNScreenHelper.h"
#import "TNWeakValue.h"
//#import "UIScrollWheelGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>

const static float ConfinedShrinkRate = 0.32;
const static float SlideMinimumVelocity = 81;

static const NSTimeInterval UIScrollViewAnimationDuration = 0.33;
static const NSTimeInterval UIScrollViewQuickAnimationDuration = 0.22;

const float UIScrollViewDecelerationRateNormal = 0.998;
const float UIScrollViewDecelerationRateFast = 0.99;

@interface UIScrollView () <_UIScrollerDelegate>
@end

@interface _UIScrollViewGestureRecognizer : UIPanGestureRecognizer <UIGestureRecognizerDelegate> @end

@implementation _UIScrollViewGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    if (self = [super initWithTarget:target action:action]) {
        self.delegate = self;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [otherGestureRecognizer isKindOfClass:[_UIScrollViewGestureRecognizer class]];
}

@end

@implementation UIScrollView {
    @package
    __weak id _delegate;
@private
    UIScrollView *_banScrollView;
    BOOL _banDragXForAllSuperScrollViews;
    BOOL _banDragYForAllSuperScrollViews;
    NSMutableSet *_banMeScrollViews;
    CGPoint _panGestureVelocity;
    CGPoint _contentOffset;
    CGSize _contentSize;
    UIEdgeInsets _contentInset;
    UIEdgeInsets _scrollIndicatorInsets;
    UIScroller *_verticalScroller;
    UIScroller *_horizontalScroller;
    BOOL _showsVerticalScrollIndicator;
    BOOL _showsHorizontalScrollIndicator;
    float _maximumZoomScale;
    float _minimumZoomScale;
    BOOL _scrollsToTop;
    UIScrollViewIndicatorStyle _indicatorStyle;
    BOOL _delaysContentTouches;
    BOOL _canCancelContentTouches;
    BOOL _pagingEnabled;
    float _decelerationRate;
    
    BOOL _bouncesZoom;
    BOOL _bounces;
    BOOL _zooming;
    BOOL _dragging;
    BOOL _decelerating;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
//    UIScrollWheelGestureRecognizer *_scrollWheelGestureRecognizer;
    
    id _scrollAnimation;
    CADisplayLink *_displayLink;
    
    struct {
        unsigned scrollViewDidScroll : 1;
        unsigned scrollViewWillBeginDragging : 1;
        unsigned scrollViewDidEndDragging : 1;
        unsigned viewForZoomingInScrollView : 1;
        unsigned scrollViewWillBeginZooming : 1;
        unsigned scrollViewDidEndZooming : 1;
        unsigned scrollViewDidZoom : 1;
        unsigned scrollViewDidEndScrollingAnimation : 1;
        unsigned scrollViewWillBeginDecelerating : 1;
        unsigned scrollViewDidEndDecelerating : 1;
    } _delegateCan;
    
    // should be flag struct
    BOOL _alwaysBounceHorizontal;
    BOOL _alwaysBounceVertical;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _banScrollView = nil;
        _banDragXForAllSuperScrollViews = NO;
        _banDragYForAllSuperScrollViews = NO;
        _banMeScrollViews = [NSMutableSet set];
        _panGestureVelocity = CGPointZero;
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
        _decelerationRate = UIScrollViewDecelerationRateNormal;
        
        _panGestureRecognizer = [[_UIScrollViewGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureDidChange:)];
        [self addGestureRecognizer:_panGestureRecognizer];
        
//        _scrollWheelGestureRecognizer = [[UIScrollWheelGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureDidChange:)];
//        [self addGestureRecognizer:_scrollWheelGestureRecognizer];
        
        _verticalScroller = [[UIScroller alloc] init];
        _verticalScroller.delegate = self;
        [self addSubview:_verticalScroller];
        
        _horizontalScroller = [[UIScroller alloc] init];
        _horizontalScroller.delegate = self;
        [self addSubview:_horizontalScroller];
        
        self.clipsToBounds = YES;
        
//        NSLog(@"scrollview sublayers:%@", self.layer.sublayers);
    }
    return self;
}

- (void)dealloc
{
    [self _cancelBanSuperScrollViewFeature];
    _horizontalScroller.delegate = nil;
    _verticalScroller.delegate = nil;
}

- (void)setDelegate:(id)newDelegate
{
    _delegate = newDelegate;
    _delegateCan.scrollViewDidScroll = [_delegate respondsToSelector:@selector(scrollViewDidScroll:)];
    _delegateCan.scrollViewWillBeginDragging = [_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)];
    _delegateCan.scrollViewDidEndDragging = [_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)];
    _delegateCan.viewForZoomingInScrollView = [_delegate respondsToSelector:@selector(viewForZoomingInScrollView:)];
    _delegateCan.scrollViewWillBeginZooming = [_delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)];
    _delegateCan.scrollViewDidEndZooming = [_delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)];
    _delegateCan.scrollViewDidZoom = [_delegate respondsToSelector:@selector(scrollViewDidZoom:)];
    _delegateCan.scrollViewDidEndScrollingAnimation = [_delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)];
    _delegateCan.scrollViewWillBeginDecelerating = [_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)];
    _delegateCan.scrollViewDidEndDecelerating = [_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)];
}

- (UIView *)_zoomingView
{
    return (_delegateCan.viewForZoomingInScrollView)? [_delegate viewForZoomingInScrollView:self] : nil;
}

- (void)setIndicatorStyle:(UIScrollViewIndicatorStyle)style
{
    _indicatorStyle = style;
    _horizontalScroller.indicatorStyle = style;
    _verticalScroller.indicatorStyle = style;
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)show
{
    _showsHorizontalScrollIndicator = show;
    [self setNeedsLayout];
}

- (void)setShowsVerticalScrollIndicator:(BOOL)show
{
    _showsVerticalScrollIndicator = show;
    [self setNeedsLayout];
}

- (BOOL)_canScrollHorizontal
{
    return self.scrollEnabled && (_contentSize.width > self.bounds.size.width);
}

- (BOOL)_canScrollVertical
{
    return self.scrollEnabled && (_contentSize.height > self.bounds.size.height);
}

- (void)_updateScrollers
{
    _verticalScroller.contentSize = _contentSize.height;
    _verticalScroller.contentOffset = _contentOffset.y;
    _horizontalScroller.contentSize = _contentSize.width;
    _horizontalScroller.contentOffset = _contentOffset.x;
    
    _verticalScroller.hidden =  !(_showsVerticalScrollIndicator && self._canScrollVertical);
    _horizontalScroller.hidden = ! (_showsHorizontalScrollIndicator && self._canScrollHorizontal);
}

- (void)setScrollEnabled:(BOOL)enabled
{
    self.panGestureRecognizer.enabled = enabled;
//    self.scrollWheelGestureRecognizer.enabled = enabled;
    [self _updateScrollers];
    [self setNeedsLayout];
}

- (BOOL)isScrollEnabled
{
//    return self.panGestureRecognizer.enabled || self.scrollWheelGestureRecognizer.enabled;
//FIXME:
    return self.panGestureRecognizer.enabled;
}

- (void)_cancelScrollAnimation
{
    [_displayLink invalidate];
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink = nil;
    
    _scrollAnimation = nil;
    
    if (_delegateCan.scrollViewDidEndScrollingAnimation) {
        [_delegate scrollViewDidEndScrollingAnimation:self];
    }
    
    if (_decelerating) {
        _horizontalScroller.alwaysVisible = NO;
        _verticalScroller.alwaysVisible = NO;
        _decelerating = NO;
        
        if (_delegateCan.scrollViewDidEndDecelerating) {
            [_delegate scrollViewDidEndDecelerating:self];
        }
    }
}

- (void)_updateScrollAnimation:(CADisplayLink *)displayLink
{
    if ([_scrollAnimation animate]) {
        [self _cancelScrollAnimation];
    }
}

- (void)_setScrollAnimation:(UIScrollViewAnimation *)animation
{
    if (_scrollAnimation) {
        [self _cancelScrollAnimation];
    }
    _scrollAnimation = animation;
    
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_updateScrollAnimation:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (CGPoint)_confinedContentOffset:(CGPoint)contentOffset
{
    const CGRect scrollerBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInset);
    CGFloat minX = -_contentInset.left;
    CGFloat maxX = _contentInset.right + _contentSize.width- self.bounds.size.width;
    CGFloat minY = -_contentInset.top;
    CGFloat maxY = _contentInset.bottom + _contentSize.height - self.bounds.size.height;
    
//    NSLog(@"contentOffset:%@ minX:%.2f minY:%.2f",NSStringFromCGPoint(contentOffset),minX,minY);
//    NSLog(@"contentSize:%@ scrollerBounds:%@",NSStringFromCGSize(_contentSize),NSStringFromCGRect(scrollerBounds));

    if ((_contentSize.width-contentOffset.x) < scrollerBounds.size.width) {
        contentOffset.x = (_contentSize.width - scrollerBounds.size.width);
    }
    
    if ((_contentSize.height-contentOffset.y) < scrollerBounds.size.height) {
        contentOffset.y = (_contentSize.height - scrollerBounds.size.height);

    }
    
    contentOffset.x = MAX(contentOffset.x,minX);
    contentOffset.y = MAX(contentOffset.y,minY);

    contentOffset.x = MIN(contentOffset.x,maxX);
    contentOffset.y = MIN(contentOffset.y,maxY);
    
    if (_contentSize.width <= scrollerBounds.size.width) {
        contentOffset.x = minX;
    }
    
    if (_contentSize.height <= scrollerBounds.size.height) {
        contentOffset.y = minY;
    }
    
//    NSLog(@"fixed offset:%@",NSStringFromCGPoint(contentOffset));
    return contentOffset;
}

- (void)_setRestrainedContentOffset:(CGPoint)offset
{
    const CGPoint confinedOffset = [self _confinedContentOffset:offset];
    const CGRect scrollerBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInset);
    
    if (!self.alwaysBounceHorizontal && _contentSize.width <= scrollerBounds.size.width) {
        offset.x = confinedOffset.x;
    }
    
    if (!self.alwaysBounceVertical && _contentSize.height <= scrollerBounds.size.height) {
        offset.y = confinedOffset.y;
    }
    
    self.contentOffset = offset;
}

- (void)_confineContent
{
    self.contentOffset = [self _confinedContentOffset:_contentOffset];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGRect bounds = self.bounds;
    const CGFloat scrollerSize = UIScrollerWidthForBoundsSize(bounds.size);
    
    _verticalScroller.frame = CGRectMake(bounds.origin.x+bounds.size.width-scrollerSize-_scrollIndicatorInsets.right,bounds.origin.y+_scrollIndicatorInsets.top,scrollerSize,bounds.size.height-_scrollIndicatorInsets.top-_scrollIndicatorInsets.bottom);
    _horizontalScroller.frame = CGRectMake(bounds.origin.x+_scrollIndicatorInsets.left,bounds.origin.y+bounds.size.height-scrollerSize-_scrollIndicatorInsets.bottom,bounds.size.width-_scrollIndicatorInsets.left-_scrollIndicatorInsets.right,scrollerSize);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self _confineContent];
}

- (void)_bringScrollersToFront
{
    [super bringSubviewToFront:_horizontalScroller];
    [super bringSubviewToFront:_verticalScroller];
}

- (void)addSubview:(UIView *)subview
{
    [super addSubview:subview];
    [self _bringScrollersToFront];
}

- (void)bringSubviewToFront:(UIView *)subview
{
    [super bringSubviewToFront:subview];
    [self _bringScrollersToFront];
}

- (void)insertSubview:(UIView *)subview atIndex:(NSInteger)index
{
    [super insertSubview:subview atIndex:index];
    [self _bringScrollersToFront];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    [self setNeedsLayout];
}

- (void)setContentOffset:(CGPoint)theOffset animated:(BOOL)animated
{
    if (animated) {
        UIScrollViewAnimationScroll *animation = [[UIScrollViewAnimationScroll alloc] initWithScrollView:self
                                                                                       fromContentOffset:self.contentOffset
                                                                                         toContentOffset:theOffset
                                                                                                duration:UIScrollViewAnimationDuration
                                                                                                   curve:UIScrollViewAnimationScrollCurveLinear];
        [self _setScrollAnimation:animation];
    } else {
        _contentOffset.x = roundf(theOffset.x);
        _contentOffset.y = roundf(theOffset.y);
        
        CGRect bounds = self.bounds;
        bounds.origin.x = _contentOffset.x;//-_contentInset.left;
        bounds.origin.y = _contentOffset.y;//-_contentInset.top;
        self.bounds = bounds;
        
        [self _updateScrollers];
        [self setNeedsLayout];
        
        if (_delegateCan.scrollViewDidScroll) {
            [_delegate scrollViewDidScroll:self];
        }
    }
}

- (void)setContentOffset:(CGPoint)theOffset
{
    [self setContentOffset:theOffset animated:NO];
}

- (void)setContentSize:(CGSize)newSize
{
    if (!CGSizeEqualToSize(newSize, _contentSize)) {
        _contentSize = newSize;
        [self _confineContent];
    }
}

- (void)flashScrollIndicators
{
    [_horizontalScroller flash];
    [_verticalScroller flash];
}

- (void)_quickFlashScrollIndicators
{
    [_horizontalScroller quickFlash];
    [_verticalScroller quickFlash];
}

- (BOOL)isTracking
{
    return NO;
}

//- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event
//{
//    UITouch *touch = [[event allTouches] anyObject];
//    const CGPoint point = [touch locationInView:self];
//    const CGFloat scrollerSize = UIScrollerWidthForBoundsSize(self.bounds.size);
//    const BOOL shouldShowHorizontal = CGRectContainsPoint(CGRectInset(_horizontalScroller.frame, -scrollerSize, -scrollerSize), point);
//    const BOOL shouldShowVertical = CGRectContainsPoint(CGRectInset(_verticalScroller.frame, -scrollerSize, -scrollerSize), point);
//    const BOOL shouldShowScrollers = (shouldShowVertical || shouldShowHorizontal || _decelerating);
//    
//    _horizontalScroller.alwaysVisible = shouldShowScrollers;
//    _verticalScroller.alwaysVisible = shouldShowScrollers;
//    
//    [super mouseMoved:delta withEvent:event];
//}

//- (void)mouseExitedView:(UIView *)exited enteredView:(UIView *)entered withEvent:(UIEvent *)event
//{
//    if (!_decelerating) {
//        if ([exited isDescendantOfView:self] && ![entered isDescendantOfView:self]) {
//            _horizontalScroller.alwaysVisible = NO;
//            _verticalScroller.alwaysVisible = NO;
//        }
//    }
//    
//    [super mouseExitedView:exited enteredView:entered withEvent:event];
//}

static const float ForceNextPageVelocity = 180;

- (UIScrollViewAnimation *)_pageSnapAnimationWithVelocity:(CGPoint)velocity
{
    const CGSize pageSize = self.bounds.size;
    const CGSize numberOfWholePages = CGSizeMake(floorf(_contentSize.width/pageSize.width), floorf(_contentSize.height/pageSize.height));
    const CGSize currentRawPage = CGSizeMake(_contentOffset.x/pageSize.width, _contentOffset.y/pageSize.height);
    const CGSize currentPage = CGSizeMake(floorf(currentRawPage.width), floorf(currentRawPage.height));
    const CGSize currentPagePercentage = CGSizeMake(1-(currentRawPage.width-currentPage.width), 1-(currentRawPage.height-currentPage.height));
    
    CGPoint finalContentOffset = CGPointZero;
    
    BOOL hasHorNextPage = (currentPage.width+1) < numberOfWholePages.width;
    BOOL hasVetNextPage = (currentPage.height+1) < numberOfWholePages.height;    
    
    float pointForeNextPageVelocity = [TNScreenHelperOfView(self) pointFromInch:ForceNextPageVelocity];
    
    if (fabsf(velocity.x) > pointForeNextPageVelocity) {
        finalContentOffset.x = pageSize.width * currentPage.width;
        if  (fabsf(velocity.x) > pointForeNextPageVelocity) {
            if (velocity.x < 0 && hasHorNextPage) {
                finalContentOffset.x = pageSize.width * (currentPage.width + 1);
            } else {
                finalContentOffset.x = pageSize.width * currentPage.width;
            }
        }
    } else {
        // if currentPagePercentage is less than 35%, then go to the next page (if any), otherwise snap to the current page
        if (currentPagePercentage.width < 0.65 && (currentPage.width+1) < numberOfWholePages.width) {
            finalContentOffset.x = pageSize.width * (currentPage.width + 1);
        } else {
            finalContentOffset.x = pageSize.width * currentPage.width;
        }
    }
    
    
    if (fabsf(velocity.y) > pointForeNextPageVelocity) {
        finalContentOffset.y = pageSize.height * currentPage.height;
        if (fabsf(velocity.y) > pointForeNextPageVelocity) {
            if (velocity.y < 0 && hasVetNextPage) {
                finalContentOffset.y = pageSize.height * (currentPage.height + 1);
            } else {
                finalContentOffset.y = pageSize.height * currentPage.height;
                if (finalContentOffset.y < 0) {
                    finalContentOffset.y = 0;
                }
            }
        }
        
    } else {
        if (currentPagePercentage.height < 0.5 && (currentPage.height+1) < numberOfWholePages.height) {
            finalContentOffset.y = pageSize.height * (currentPage.height + 1);
        } else {
            finalContentOffset.y = pageSize.height * currentPage.height;
        }
    }
    
    finalContentOffset = [self _confinedContentOffset:finalContentOffset];
    
    // quickly animate the snap (if necessary)
    if (!CGPointEqualToPoint(finalContentOffset, _contentOffset)) {
        return [[UIScrollViewAnimationScroll alloc] initWithScrollView:self
                                                      fromContentOffset:_contentOffset
                                                        toContentOffset:finalContentOffset
                                                               duration:UIScrollViewQuickAnimationDuration
                                                                  curve:UIScrollViewAnimationScrollCurveQuadraticEaseOut];
    } else {
        return nil;
    }
}

- (UIScrollViewAnimation *)_decelerationAnimationWithVelocity:(CGPoint)velocity
{
    const CGPoint confinedOffset = [self _confinedContentOffset:_contentOffset];
    velocity = CGPointMake(-velocity.x, -velocity.y);
    
    if (CGPointEqualToPoint(confinedOffset, _contentOffset) &&
        fabs(velocity.x) + fabs(velocity.y) <= [TNScreenHelperOfView(self) pointFromInch:SlideMinimumVelocity]) {
        return nil;
    }
    
    // if we've pulled up the content outside it's bounds, we don't want to register any flick momentum there and instead just
    // have the animation pull the content back into place immediately.
    if (confinedOffset.x != _contentOffset.x) {
        velocity.x = 0;
    }
    if (confinedOffset.y != _contentOffset.y) {
        velocity.y = 0;
    }
    
    return [[UIScrollViewAnimationDeceleration alloc] initWithScrollView:self velocity:velocity];
}

- (void)_beginDragging
{
    if (!_dragging) {
        _dragging = YES;
        
        _horizontalScroller.alwaysVisible = YES;
        _verticalScroller.alwaysVisible = YES;
        _panGestureVelocity = CGPointZero;
        
        if (_scrollAnimation) {
            [self _cancelScrollAnimation];
        }
        
        if (_delegateCan.scrollViewWillBeginDragging) {
            [_delegate scrollViewWillBeginDragging:self];
        }
        [self _searchAndBanFirstSuperScrollView];
    }
}

- (BOOL)isDragging
{
    return _dragging;
}

- (void)_endDragging
{
    if (_dragging) {
        _dragging = NO;
        
        UIScrollViewAnimation *decelerationAnimation = _pagingEnabled?
        [self _pageSnapAnimationWithVelocity:_panGestureVelocity] :
        [self _decelerationAnimationWithVelocity:_panGestureVelocity];
        
        if (_delegateCan.scrollViewDidEndDragging) {
            [_delegate scrollViewDidEndDragging:self willDecelerate:(decelerationAnimation != nil)];
        }
        
        if (decelerationAnimation) {
            [self _setScrollAnimation:decelerationAnimation];
            
            _horizontalScroller.alwaysVisible = YES;
            _verticalScroller.alwaysVisible = YES;
            _decelerating = YES;
            
            if (_delegateCan.scrollViewWillBeginDecelerating) {
                [_delegate scrollViewWillBeginDecelerating:self];
            }
        } else {
            _horizontalScroller.alwaysVisible = NO;
            _verticalScroller.alwaysVisible = NO;
            [self _confineContent];
        }
        [self _cancelBanSuperScrollViewFeature];
    }
}

- (void)_dragBy:(CGPoint)delta
{
    
    if (_dragging && !CGPointEqualToPoint(delta, CGPointZero)) {
        _horizontalScroller.alwaysVisible = YES;
        _verticalScroller.alwaysVisible = YES;
        
        delta.x = -delta.x;
        delta.y = -delta.y;
        
        delta = [self _clearBlockedPartWithVecotr:delta];
        
        const CGPoint originalOffset = self.contentOffset;
        
        CGPoint proposedOffset = originalOffset;
        proposedOffset.x += delta.x;
        proposedOffset.y += delta.y;
        
        const CGPoint confinedOffset = [self _confinedContentOffset:proposedOffset];
        
        [self _setBanDragXForAllSuperScrollViews: confinedOffset.x == proposedOffset.x];
        [self _setBanDragYForAllSuperScrollViews: confinedOffset.y == proposedOffset.y];
        
        if (self.bounces) {
            BOOL shouldHorizontalBounce = (fabs(proposedOffset.x - confinedOffset.x) > 0);
            BOOL shouldVerticalBounce = (fabs(proposedOffset.y - confinedOffset.y) > 0);
            
            if (shouldHorizontalBounce) {
                proposedOffset.x = originalOffset.x + (ConfinedShrinkRate * delta.x);
            }
            
            if (shouldVerticalBounce) {
                proposedOffset.y = originalOffset.y + (ConfinedShrinkRate * delta.y);
            }
            
            [self _setRestrainedContentOffset:proposedOffset];
        } else {
            [self setContentOffset:confinedOffset];
        }
    }
}

- (void)_gestureDidChange:(UIGestureRecognizer *)gesture
{
    // the scrolling gestures are broken into two components due to the somewhat fundamental differences
    // in how they are handled by the system. The UIPanGestureRecognizer will only track scrolling gestures
    // that come from actual touch scroller devices. This does *not* include old fashioned mouse wheels.
    // the non-standard UIScrollWheelGestureRecognizer is a discrete recognizer which only responds to
    // non-gesture scroll events such as those from non-touch devices. HOWEVER the system sends momentum
    // scroll events *after* the touch gesture has ended which allows for us to distinguish the difference
    // here between actual touch gestures and the momentum gestures and thus feed them into the playing
    // deceleration animation as we receive them so that we can preserve the system's proper feel for that.
    
    // Also important to note is that with a legacy scroll device, each movement of the wheel is going to
    // trigger a beginDrag, dragged, endDragged sequence. I believe that's an acceptable compromise however
    // it might cause some potentially strange behavior in client code that is not expecting such rapid
    // state changes along these lines.
    
    // Another note is that only touch-based panning gestures will trigger calls to _dragBy: which means
    // that only touch devices can possibly pull the content outside of the scroll view's bounds while
    // active. An old fashioned wheel will not be able to do that and its scroll events are confined to
    // the bounds of the scroll view.
    
    // There are some semi-legacy devices like the magic mouse which 10.6 doesn't seem to consider a true
    // touch device, so it doesn't send the gestureBegin/ended stuff that's used to recognize such things
    // but it *will* send momentum events. This means that those devices on 10.6 won't give you the feeling
    // of being able to grab and pull your content away from the bounds like a proper touch trackpad will.
    // As of 10.7 it appears Apple fixed this and they do actually send the proper gesture events, so on
    // 10.7 the magic mouse should end up acting like any other touch input device as far as we're concerned.
    
    // Momentum scrolling doesn't work terribly well with how the paging stuff is now handled. Something
    // could be improved there. I'm not sure if the paging animation should just pretend it's longer to
    // kind of "mask" the OS' momentum events, or if a flag should be set, or if it should work so that
    // even in paging mode the deceleration and stuff happens like usual and it only snaps to the correct
    // page *after* the usual deceleration is done. I can't decide what might be best, but since we
    // don't use paging mode in Twitterrific at the moment, I'm not suffeciently motivated to worry about it. :)
    
    if (gesture == _panGestureRecognizer) {
        
        if (_panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self _beginDragging];
            
        } else if (_panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            [self _dragBy:[_panGestureRecognizer translationInView:self]];
            _panGestureVelocity = [self _clearBlockedPartWithVecotr:[_panGestureRecognizer velocityInView:self]];
            [_panGestureRecognizer setTranslation:CGPointZero inView:self];
            
        } else if (_panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self _endDragging];
        }
    } /* else if (gesture == _scrollWheelGestureRecognizer) {
        if (_scrollWheelGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
            const CGPoint delta = [_scrollWheelGestureRecognizer translationInView:self];
            
            if (_decelerating) {
                // note that we might be "decelerating" but actually just snapping to a page boundary in paging mode,
                // so we need to verify if we can actually send this message to the current animation or not.
                // if we can't, then we'll just eat the scroll event and let the animation finish instead.
                // additional note: the reason this is done this way at all is so that the system's momentum
                // messages can be preserved perfectly rather than trying to emulate them myself. this results
                // in a better feeling end product even if the bouncing at the edges isn't quite entirely right.
                // see notes in UIScrollViewAnimationDeceleration.m for more.
                if ([_scrollAnimation respondsToSelector:@selector(momentumScrollBy:)]) {
                    [_scrollAnimation momentumScrollBy:delta];
                }
            } else {
                CGPoint offset = self.contentOffset;
                offset.x += delta.x;
                offset.y += delta.y;
                offset = [self _confinedContentOffset:offset];
                
                if (!CGPointEqualToPoint(offset, _contentOffset)) {
                    [self _beginDragging];
                    self.contentOffset = offset;
                    [self _endDraggingWithDecelerationVelocity:CGPointZero];
                }
                
                [self _quickFlashScrollIndicators];
            }
        }
    } */
}

- (CGPoint)_clearBlockedPartWithVecotr:(CGPoint)vector
{
    for (TNWeakValue *weakValue in _banMeScrollViews) {
        UIScrollView *scrollView = weakValue.value;
        if (scrollView) {
            vector = [scrollView _blockProjectionOfVecotr:vector inView:self];
        }
    }
    return vector;
}

- (CGPoint)_blockProjectionOfVecotr:(CGPoint)vector inView:(UIView *)view
{
    CGPoint zero = [self convertPoint:CGPointZero fromView:view];
    vector = [self convertPoint:vector fromView:view];
    vector = CGPointMake(vector.x - zero.x, vector.y - zero.y);
    
    if (_banDragXForAllSuperScrollViews) {
        vector.x = 0.0;
    }
    if (_banDragYForAllSuperScrollViews) {
        vector.y = 0.0;
    }
    vector = [self convertPoint:vector toView:view];
    zero = [self convertPoint:CGPointZero toView:view];
    
    return CGPointMake(vector.x - zero.x, vector.y - zero.y);
}

- (void)_setBanDragXForAllSuperScrollViews:(BOOL)banSuperScrollView
{
    _banDragXForAllSuperScrollViews = banSuperScrollView;
}

- (void)_setBanDragYForAllSuperScrollViews:(BOOL)banSuperScrollView
{
    _banDragYForAllSuperScrollViews = banSuperScrollView;
}

- (void)_searchAndBanFirstSuperScrollView
{
    if (_banScrollView) {
        return;
    }
    UIView *view = self.superview;
    while (view) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            [scrollView _banScrollFeatureBy:self];
            _banScrollView = scrollView;
            break;
        }
        view = view.superview;
    }
}

- (void)_cancelBanSuperScrollViewFeature
{
    if (_banScrollView) {
        [_banScrollView _cancelBanScrollFeatureBy:self];
        _banScrollView = nil;
    }
}

- (void)_banScrollFeatureBy:(UIScrollView *)banMeScrollView
{
    [_banMeScrollViews addObject:[TNWeakValue valueWithWeakObject:banMeScrollView]];
}

- (void)_cancelBanScrollFeatureBy:(UIScrollView *)banMeScrollView
{
    [_banMeScrollViews removeObject:[TNWeakValue valueWithWeakObject:banMeScrollView]];
}

- (BOOL)_hasBanByOtherScrollView
{
    return _banMeScrollViews.count > 0;
}

- (void)_UIScrollerDidBeginDragging:(UIScroller *)scroller withEvent:(UIEvent *)event
{
    [self _beginDragging];
}

- (void)_UIScroller:(UIScroller *)scroller contentOffsetDidChange:(CGFloat)newOffset
{
    if (scroller == _verticalScroller) {
        [self setContentOffset:CGPointMake(self.contentOffset.x,newOffset) animated:NO];
    } else if (scroller == _horizontalScroller) {
        [self setContentOffset:CGPointMake(newOffset,self.contentOffset.y) animated:NO];
    }
}

- (void)_UIScrollerDidEndDragging:(UIScroller *)scroller withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    const CGPoint point = [touch locationInView:self];
    
    if (!CGRectContainsPoint(scroller.frame,point)) {
        scroller.alwaysVisible = NO;
    }
    
    [self _endDragging];
}

- (BOOL)isDecelerating
{
    return NO;
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    const CGRect contentRect = CGRectMake(0,0,_contentSize.width, _contentSize.height);
    const CGRect visibleRect = self.bounds;
    CGRect goalRect = CGRectIntersection(rect, contentRect);
    
    if (!CGRectIsNull(goalRect) && !CGRectContainsRect(visibleRect, goalRect)) {
        
        // clamp the goal rect to the largest possible size for it given the visible space available
        // this causes it to prefer the top-left of the rect if the rect is too big
        goalRect.size.width = MIN(goalRect.size.width, visibleRect.size.width);
        goalRect.size.height = MIN(goalRect.size.height, visibleRect.size.height);
        
        CGPoint offset = self.contentOffset;
        
        if (CGRectGetMaxY(goalRect) > CGRectGetMaxY(visibleRect)) {
            offset.y += CGRectGetMaxY(goalRect) - CGRectGetMaxY(visibleRect);
        } else if (CGRectGetMinY(goalRect) < CGRectGetMinY(visibleRect)) {
            offset.y += CGRectGetMinY(goalRect) - CGRectGetMinY(visibleRect);
        }
        
        if (CGRectGetMaxX(goalRect) > CGRectGetMaxX(visibleRect)) {
            offset.x += CGRectGetMaxX(goalRect) - CGRectGetMaxX(visibleRect);
        } else if (CGRectGetMinX(goalRect) < CGRectGetMinX(visibleRect)) {
            offset.x += CGRectGetMinX(goalRect) - CGRectGetMinX(visibleRect);
        }
        
        [self setContentOffset:offset animated:animated];
    }
}

- (BOOL)isZoomBouncing
{
    return NO;
}

- (float)zoomScale
{
    UIView *zoomingView = [self _zoomingView];
    
    // it seems weird to return the "a" component of the transform for this, but after some messing around with the real UIKit, I'm
    // reasonably certain that's how it is doing it.
    return zoomingView? zoomingView.transform.a : 1.f;
}

- (void)setZoomScale:(float)scale animated:(BOOL)animated
{
    UIView *zoomingView = [self _zoomingView];
    scale = MIN(MAX(scale, _minimumZoomScale), _maximumZoomScale);
    
    if (zoomingView && self.zoomScale != scale) {
        [UIView animateWithDuration:animated? UIScrollViewAnimationDuration : 0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^(void) {
                             zoomingView.transform = CGAffineTransformMakeScale(scale, scale);
                             const CGSize size = zoomingView.frame.size;
                             zoomingView.layer.position = CGPointMake(size.width/2.f, size.height/2.f);
                             self.contentSize = size;
                         }
                         completion:NULL];
    }
}

- (void)setZoomScale:(float)scale
{
    [self setZoomScale:scale animated:NO];
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated
{
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; frame = (%.0f %.0f; %.0f %.0f); clipsToBounds = %@; layer = %@; contentOffset = {%.0f, %.0f}>", [self className], self, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height, (self.clipsToBounds ? @"YES" : @"NO"), self.layer, self.contentOffset.x, self.contentOffset.y];
}

@end
