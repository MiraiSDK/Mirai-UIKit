//
//  UIView.m
//  UIKit
//
//  Created by Chen Yonghui on 12/6/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIView.h"
#import <QuartzCore/CALayer.h>
#import "UIGraphics.h"
#import "UIColor.h"
#import "UIGeometry.h"
#import "UIWindow.h"
#import "UIViewController.h"
#import "UIViewLayoutManager.h"
#import "UIApplication+UIPrivate.h"
#import "UIGestureRecognizer.h"
#import "UIGestureRecognizer+UIPrivate.h"

#import "UIKit+Android.h"

//Animation
#import "UIViewAnimationGroup.h"
#import "UIViewBlockAnimationDelegate.h"
#import <dispatch/dispatch.h>

NSString *const UIViewFrameDidChangeNotification = @"UIViewFrameDidChangeNotification";
NSString *const UIViewBoundsDidChangeNotification = @"UIViewBoundsDidChangeNotification";
NSString *const UIViewDidMoveToSuperviewNotification = @"UIViewDidMoveToSuperviewNotification";
NSString *const UIViewHiddenDidChangeNotification = @"UIViewHiddenDidChangeNotification";

static NSMutableArray *_animationGroups;
static BOOL _animationsEnabled = YES;

@implementation UIView {
    @package
    BOOL _implementsDrawRect;
    NSMutableSet *_subviews;
    
    UIColor *_backgroundColor;
    UIViewContentMode _contentMode;
    
    BOOL _clearsContextBeforeDrawing;
    BOOL _clipsToBounds;
    
    UIView *_superview;
    UIWindow *_window;
    __weak UIViewController *_viewController;
    
    BOOL _autoresizesSubviews;
    BOOL _needsDidAppearOrDisappear;

    NSMutableSet *_gestureRecognizers;
    
    struct {
        unsigned int userInteractionDisabled:1;
        unsigned int implementsDrawRect:1;
        unsigned int implementsDidScroll:1;
        unsigned int implementsMouseTracking:1;
        unsigned int hasBackgroundColor:1;
        unsigned int isOpaque:1;
        unsigned int becomeFirstResponderWhenCapable:1;
        unsigned int interceptMouseEvent:1;
        unsigned int deallocating:1;
        unsigned int debugFlash:1;
        unsigned int debugSkippedSetNeedsDisplay:1;
        unsigned int debugScheduledDisplayIsRequired:1;
        unsigned int isInAWindow:1;
        unsigned int isAncestorOfFirstResponder:1;
        unsigned int dontAutoresizeSubviews:1;
        unsigned int autoresizeMask:6;
        unsigned int patternBackground:1;
        unsigned int fixedBackgroundPattern:1;
        unsigned int dontAnimate:1;
        unsigned int superLayerIsView:1;
        unsigned int layerKitPatternDrawing:1;
        unsigned int multipleTouchEnabled:1;
        unsigned int exclusiveTouch:1;
        unsigned int hasViewController:1;
        unsigned int needsDidAppearOrDisappear:1;
        unsigned int gesturesEnabled:1;
        unsigned int deliversTouchesForGesturesToSuperview:1;
        unsigned int chargeEnabled:1;
        unsigned int skipsSubviewEnumeration:1;
        unsigned int needsDisplayOnBoundsChange:1;
        unsigned int hasTiledLayer:1;
        unsigned int hasLargeContent:1;
        unsigned int unused:1;
        unsigned int traversalMark:1;
        unsigned int appearanceIsInvalid:1;
        unsigned int monitorsSubtree:1;
        unsigned int hostsAutolayoutEngine:1;
        unsigned int constraintsAreClean:1;
        unsigned int subviewLayoutConstraintsAreClean:1;
        unsigned int intrinsicContentSizeConstraintsAreClean:1;
        unsigned int potentiallyHasDanglyConstraints:1;
        unsigned int doesNotTranslateAutoresizingMaskIntoConstraints:1;
        unsigned int autolayoutIsClean:1;
        unsigned int subviewsAutolayoutIsClean:1;
        unsigned int layoutFlushingDisabled:1;
        unsigned int layingOutFromConstraints:1;
        unsigned int wantsAutolayout:1;
        unsigned int subviewWantsAutolayout:1;
        unsigned int isApplyingValuesFromEngine:1;
        unsigned int isInAutolayout:1;
        unsigned int isUpdatingAutoresizingConstraints:1;
        unsigned int isUpdatingConstraints:1;
        unsigned int stayHiddenAwaitingReuse:1;
        unsigned int stayHiddenAfterReuse:1;
        unsigned int skippedLayoutWhileHiddenForReuse:1;
        unsigned int hasMaskView:1;
        unsigned int hasVisualAltitude:1;
        unsigned int hasBackdropMaskViews:1;
        unsigned int backdropMaskViewFlags:3;
        unsigned int delaysTouchesForSystemGestures:1;
        unsigned int subclassShouldDelayTouchForSystemGestures:1;
        unsigned int hasMotionEffects:1;
        unsigned int backdropOverlayMode:2;
        unsigned int tintAdjustmentMode:2;
        unsigned int isReferenceView:1;
    } _viewFlags;
}

+ (Class)layerClass
{
    return [CALayer class];
}

+ (BOOL)_instanceImplementsDrawRect
{
    return [UIView instanceMethodForSelector:@selector(drawRect:)] != [self instanceMethodForSelector:@selector(drawRect:)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        Class class = object_getClass(self);
        _implementsDrawRect = [[self class] _instanceImplementsDrawRect];
        _clearsContextBeforeDrawing = YES;
        _autoresizesSubviews = YES;

        _subviews = [NSMutableSet set];
        _gestureRecognizers = [[NSMutableSet alloc] init];
        
        _layer = [[[class layerClass] alloc] init];
        _layer.delegate = self;
        _layer.layoutManager = [UIViewLayoutManager layoutManager];
        
        self.contentMode = UIViewContentModeScaleToFill;
        self.contentScaleFactor = 0;
        
        self.frame = frame;
        self.alpha = 1;
        self.opaque = YES;
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc
{
    [[_subviews allObjects] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_layer removeFromSuperlayer];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    // For notes about why this is done, see displayLayer: above.
    //
    // with GNU's runtime, compare selector must use sel_isEqual()
    //
    if (sel_isEqual(aSelector, @selector(displayLayer:))) {
        return !_implementsDrawRect;
    } else {
        BOOL responds = [super respondsToSelector:aSelector];
        return responds;
    }
}

- (BOOL)isUserInteractionEnabled
{
    return  !_viewFlags.userInteractionDisabled;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    _viewFlags.userInteractionDisabled = !userInteractionEnabled;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; frame = %@; hidden = %@; layer = %@>", [self className], self, NSStringFromCGRect(self.frame), (self.hidden ? @"YES" : @"NO"), self.layer];
}

- (UIResponder *)nextResponder
{
    return (UIResponder *)_viewController ?: (UIResponder *)_superview;
}

@end

@implementation UIView (UIViewGeometry)

- (void)setAutoresizingMask:(UIViewAutoresizing)autoresizingMask
{
    _viewFlags.autoresizeMask = autoresizingMask;
}

- (UIViewAutoresizing)autoresizingMask
{
    return _viewFlags.autoresizeMask;
}

- (void)_superviewSizeDidChangeFrom:(CGSize)oldSize to:(CGSize)newSize
{
    if (_viewFlags.autoresizeMask != UIViewAutoresizingNone) {
        CGRect frame = self.frame;
        const CGSize delta = CGSizeMake(newSize.width-oldSize.width, newSize.height-oldSize.height);
        
#define hasAutoresizingFor(x) ((_viewFlags.autoresizeMask & (x)) == (x))
        
        /*
         
         top + bottom + height      => y = floor(y + (y / HEIGHT * delta)); height = floor(height + (height / HEIGHT * delta))
         top + height               => t = y + height; y = floor(y + (y / t * delta); height = floor(height + (height / t * delta);
         bottom + height            => height = floor(height + (height / (HEIGHT - y) * delta))
         top + bottom               => y = floor(y + (delta / 2))
         height                     => height = floor(height + delta)
         top                        => y = floor(y + delta)
         bottom                     => y = floor(y)
         
         */
        
        if (oldSize.height == 0) {
            frame.size.height = newSize.height;
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin)) {
            frame.origin.y = floorf(frame.origin.y + (frame.origin.y / oldSize.height * delta.height));
            frame.size.height = floorf(frame.size.height + (frame.size.height / oldSize.height * delta.height));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight)) {
            const CGFloat t = frame.origin.y + frame.size.height;
            frame.origin.y = floorf(frame.origin.y + (frame.origin.y / t * delta.height));
            frame.size.height = floorf(frame.size.height + (frame.size.height / t * delta.height));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight)) {
            frame.size.height = floorf(frame.size.height + (frame.size.height / (oldSize.height - frame.origin.y) * delta.height));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin)) {
            frame.origin.y = floorf(frame.origin.y + (delta.height / 2.f));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleHeight)) {
            frame.size.height = floorf(frame.size.height + delta.height);
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleTopMargin)) {
            frame.origin.y = floorf(frame.origin.y + delta.height);
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleBottomMargin)) {
            frame.origin.y = floorf(frame.origin.y);
        }
        
        if (oldSize.width == 0) {
            frame.size.width = newSize.width;
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin)) {
            frame.origin.x = floorf(frame.origin.x + (frame.origin.x / oldSize.width * delta.width));
            frame.size.width = floorf(frame.size.width + (frame.size.width / oldSize.width * delta.width));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth)) {
            const CGFloat t = frame.origin.x + frame.size.width;
            frame.origin.x = floorf(frame.origin.x + (frame.origin.x / t * delta.width));
            frame.size.width = floorf(frame.size.width + (frame.size.width / t * delta.width));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth)) {
            frame.size.width = floorf(frame.size.width + (frame.size.width / (oldSize.width - frame.origin.x) * delta.width));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin)) {
            frame.origin.x = floorf(frame.origin.x + (delta.width / 2.f));
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleWidth)) {
            frame.size.width = floorf(frame.size.width + delta.width);
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleLeftMargin)) {
            frame.origin.x = floorf(frame.origin.x + delta.width);
        } else if (hasAutoresizingFor(UIViewAutoresizingFlexibleRightMargin)) {
            frame.origin.x = floorf(frame.origin.x);
        }
        
        self.frame = frame;
    }
}

- (void)_boundsDidChangeFrom:(CGRect)oldBounds to:(CGRect)newBounds
{
    if (!CGRectEqualToRect(oldBounds, newBounds)) {
        // setNeedsLayout doesn't seem like it should be necessary, however there was a rendering bug in a table in Flamingo that
        // went away when this was placed here. There must be some strange ordering issue with how that layout manager stuff works.
        // I never quite narrowed it down. This was an easy fix, if perhaps not ideal.
        [self setNeedsLayout];
        
        if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
            if (_autoresizesSubviews) {
                for (UIView *subview in [_subviews allObjects]) {
                    [subview _superviewSizeDidChangeFrom:oldBounds.size to:newBounds.size];
                }
            }
        }
    }
}

+ (NSSet *)keyPathsForValuesAffectingFrame
{
    return [NSSet setWithObject:@"center"];
}

- (CGRect)frame
{
    return _layer.frame;
}

- (void)setFrame:(CGRect)newFrame
{
    if (!CGRectEqualToRect(newFrame,_layer.frame)) {
        CGRect oldBounds = _layer.bounds;
        NSLog(@"set layer frame: {%.2f,%.2f,%.2f,%.2f}",newFrame.origin.x,newFrame.origin.y,newFrame.size.width,newFrame.size.height);
        
        CGPoint newOrigin = newFrame.origin;
        CGAffineTransform invertedTransform = CGAffineTransformInvert(self.transform);
        CGSize  transformedSize = CGSizeApplyAffineTransform(newFrame.size, invertedTransform);
        
        CGRect bounds = _layer.bounds;
        bounds.size = transformedSize;
        bounds = CGRectIntegral(bounds);
        
        CGPoint anchorPoint = _layer.anchorPoint;
        CGPoint position = CGPointMake(newOrigin.x + (newFrame.size.width * anchorPoint.x),
                                newOrigin.y + (newFrame.size.height * anchorPoint.y));

        _layer.bounds = bounds;
        _layer.position = position;
        
        [self _boundsDidChangeFrom:oldBounds to:_layer.bounds];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIViewFrameDidChangeNotification object:self];
    }
}

- (CGRect)bounds
{
    return _layer.bounds;
}

- (void)setBounds:(CGRect)aBounds
{
    if (!CGRectEqualToRect(aBounds,_layer.bounds)) {
        CGRect oldBounds = _layer.bounds;
        _layer.bounds = aBounds;
        [self _boundsDidChangeFrom:oldBounds to:aBounds];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIViewBoundsDidChangeNotification object:self];
    }
}

- (CGPoint)center
{
    return _layer.position;
}

- (void)setCenter:(CGPoint)aCenter
{
    _layer.position = aCenter;
}

- (CGAffineTransform)transform
{
    return _layer.affineTransform;
}

- (void)setTransform:(CGAffineTransform)aTransform
{
    _layer.affineTransform = aTransform;
}

- (BOOL)isMultipleTouchEnabled
{
    return _viewFlags.multipleTouchEnabled;
}

- (void)setMultipleTouchEnabled:(BOOL)flag
{
    _viewFlags.multipleTouchEnabled = flag;
}
- (BOOL)isExclusiveTouch
{
    return _viewFlags.exclusiveTouch;
}

- (void)setExclusiveTouch:(BOOL)flag
{
    _viewFlags.exclusiveTouch = flag;
}

- (BOOL)autoresizesSubviews
{
    return _autoresizesSubviews;
}

- (void)setAutoresizesSubviews:(BOOL)flag
{
    if (_autoresizesSubviews != flag) {
        _autoresizesSubviews = flag;
    }
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    NSLog(@"Unimplementd Method: %s",__PRETTY_FUNCTION__);
}

- (CGFloat)contentScaleFactor
{
    NSLog(@"Unimplementd Method: %s",__PRETTY_FUNCTION__);
    return 0.0f;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.hidden || !self.userInteractionEnabled || self.alpha < 0.01 || ![self pointInside:point withEvent:event]) {
        return nil;
    } else {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            UIView *hitView = [subview hitTest:[subview convertPoint:point fromView:self] withEvent:event];
            if (hitView) {
                return hitView;
            }
        }
        return self;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(self.bounds, point);
}

- (CGPoint)convertPoint:(CGPoint)toConvert toView:(UIView *)toView
{
    // NOTE: this is a lot more complex than it needs to be - I just noticed the docs say this method requires toView and self to
    // belong to the same UIWindow! arg! leaving this for now because, well, it's neat.. but also I'm too tired to really ponder
    // all the implications of a change to something so "low level".
    
    // See note in convertPoint:fromView: for some explaination about why this is done... :/
    if (toView && (self.window.screen == toView.window.screen)) {
        return [self.layer convertPoint:toConvert toLayer:toView.layer];
    } else {
        // Convert to our window's coordinate space.
        toConvert = [self.layer convertPoint:toConvert toLayer:self.window.layer];
        
        if (toView) {
            // Convert from one window's coordinate space to another.
            toConvert = [self.window convertPoint:toConvert toWindow:toView.window];
            
            // Convert from toView's window down to toView's coordinate space.
            toConvert = [toView.window.layer convertPoint:toConvert toLayer:toView.layer];
        }
        
        return toConvert;
    }
}

- (CGPoint)convertPoint:(CGPoint)toConvert fromView:(UIView *)fromView
{
    // NOTE: this is a lot more complex than it needs to be - I just noticed the docs say this method requires fromView and self to
    // belong to the same UIWindow! arg! leaving this for now because, well, it's neat.. but also I'm too tired to really ponder
    // all the implications of a change to something so "low level".
    
    if (fromView) {
        // If the screens are the same, then we know they share a common parent CALayer, so we can convert directly with the layer's
        // conversion method. If not, though, we need to do something a bit more complicated.
        if (fromView && (self.window.screen == fromView.window.screen)) {
            return [fromView.layer convertPoint:toConvert toLayer:self.layer];
        } else {
            // Convert coordinate to fromView's window base coordinates.
            toConvert = [fromView.layer convertPoint:toConvert toLayer:fromView.window.layer];
            
            // Now convert from fromView's window to our own window.
            toConvert = [fromView.window convertPoint:toConvert toWindow:self.window];
        }
    }
    
    // Convert from our window coordinate space into our own coordinate space.
    return [self.window.layer convertPoint:toConvert toLayer:self.layer];
}

- (CGRect)convertRect:(CGRect)toConvert fromView:(UIView *)fromView
{
    if (fromView == nil) {
        return [self.layer convertRect:toConvert fromLayer:self.window.layer];
    }
    
    return [self.layer convertRect:toConvert fromLayer:fromView.layer];
}

- (CGRect)convertRect:(CGRect)toConvert toView:(UIView *)toView
{
    if (toView == nil) {
        return [self.layer convertRect:toConvert toLayer:self.window.layer];
    }
    return [self.layer convertRect:toConvert toLayer:toView.layer];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return size;
}

- (void)sizeToFit
{
    CGRect frame = self.frame;
    frame.size = [self sizeThatFits:frame.size];
    self.frame = frame;
}

@end

@implementation UIView (UIViewHierarchy)
- (UIView *)superview
{
    return _superview;
}

- (void)setSuperview:(UIView *)aSuperview
{
    if (_superview != aSuperview) {
        _superview = aSuperview;
    }
}

- (NSArray *)subviews
{
    NSArray *sublayers = _layer.sublayers;
    NSMutableArray *subviews = [NSMutableArray arrayWithCapacity:[sublayers count]];
    
    // This builds the results from the layer instead of just using _subviews because I want the results to match
    // the order that CALayer has them. It's unclear in the docs if the returned order from this method is guarenteed or not,
    // however several other aspects of the system (namely the hit testing) depends on this order being correct.
    for (CALayer *layer in sublayers) {
        id potentialView = [layer delegate];
        if ([_subviews containsObject:potentialView]) {
            [subviews addObject:potentialView];
        }
    }
    
    return subviews;
}

- (void)_setViewController:(UIViewController *)theViewController
{
    _viewController = theViewController;
}

- (UIViewController *)_viewController
{
    return _viewController;
}

- (UIWindow *)window
{
    return _superview.window;
}

- (void)removeFromSuperview
{
    if (_superview) {
        [[UIApplication sharedApplication] _removeViewFromTouches:self];
        
        UIWindow *oldWindow = self.window;
        
        if (_needsDidAppearOrDisappear && [self _viewController]) {
            [[self _viewController] viewWillDisappear:NO];
        }
        
        [_superview willRemoveSubview:self];
        [self _willMoveFromWindow:oldWindow toWindow:nil];
        [self willMoveToSuperview:nil];
        
        [self willChangeValueForKey:@"superview"];
        [_layer removeFromSuperlayer];
        [_superview->_subviews removeObject:self];
        _superview = nil;
        [self didChangeValueForKey:@"superview"];
        
        [self _didMoveFromWindow:oldWindow toWindow:nil];
        [self didMoveToSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIViewDidMoveToSuperviewNotification object:self];
        
        if (_needsDidAppearOrDisappear && [self _viewController]) {
            [[self _viewController] viewDidDisappear:NO];
        }
    }
}

- (void)_willMoveFromWindow:(UIWindow *)fromWindow toWindow:(UIWindow *)toWindow
{
    if (fromWindow != toWindow) {
        
        // need to manage the responder chain. apparently UIKit (at least by version 4.2) seems to make sure that if a view was first responder
        // and it or it's parent views are disconnected from their window, the first responder gets reset to nil. Honestly, I don't think this
        // was always true - but it's certainly a much better and less-crashy design. Hopefully this check here replicates the behavior properly.
        if ([self isFirstResponder]) {
            [self resignFirstResponder];
        }
        
//        [self _setAppearanceNeedsUpdate];
        [self willMoveToWindow:toWindow];
        
        for (UIView *subview in self.subviews) {
            [subview _willMoveFromWindow:fromWindow toWindow:toWindow];
        }
    }
}

- (void)_didMoveFromWindow:(UIWindow *)fromWindow toWindow:(UIWindow *)toWindow
{
    if (fromWindow != toWindow) {
        [self didMoveToWindow];
        
        for (UIView *subview in self.subviews) {
            [subview _didMoveFromWindow:fromWindow toWindow:toWindow];
        }
    }
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index
{
    [self addSubview:view];
    [_layer insertSublayer:view.layer atIndex:index];
}

- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2
{
    
} //exchangeSubviewAtIndex:withSubviewAtIndex:

- (BOOL)_subviewControllersNeedAppearAndDisappear
{
    UIView *view = self;
    
    while (view) {
        if ([view _viewController] != nil) {
            return NO;
        } else {
            view = [view superview];
        }
    }
    
    return YES;
}

- (void)addSubview:(UIView *)subview
{
    NSAssert((!subview || [subview isKindOfClass:[UIView class]]), @"the subview must be a UIView");

    if (subview && subview.superview != self) {
        UIWindow *oldWindow = subview.window;
        UIWindow *newWindow = self.window;
        
        subview->_needsDidAppearOrDisappear = [self _subviewControllersNeedAppearAndDisappear];
        
        if ([subview _viewController] && subview->_needsDidAppearOrDisappear) {
            [[subview _viewController] viewWillAppear:NO];
        }
        
        [subview _willMoveFromWindow:oldWindow toWindow:newWindow];
        [subview willMoveToSuperview:self];
        
        {
            if (subview.superview) {
                [subview.layer removeFromSuperlayer];
                [subview.superview->_subviews removeObject:subview];
            }
            
            [subview willChangeValueForKey:@"superview"];
            [_subviews addObject:subview];
            subview->_superview = self;
            [_layer addSublayer:subview.layer];
            [subview didChangeValueForKey:@"superview"];
        }
        
//        if (oldWindow.screen != newWindow.screen) {
//            [subview _didMoveToScreen];
//        }
        
        [subview _didMoveFromWindow:oldWindow toWindow:newWindow];
        [subview didMoveToSuperview];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UIViewDidMoveToSuperviewNotification object:subview];
        
        [self didAddSubview:subview];
        
        if ([subview _viewController] && subview->_needsDidAppearOrDisappear) {
            [[subview _viewController] viewDidAppear:NO];
        }
    }
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
{
    [self addSubview:view];
    [_layer insertSublayer:view.layer below:siblingSubview.layer];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview
{
    [self addSubview:view];
    [_layer insertSublayer:view.layer above:siblingSubview.layer];
}

- (void)bringSubviewToFront:(UIView *)view
{
    if (view.superview == self) {
        [_layer insertSublayer:view.layer above:[[_layer sublayers] lastObject]];
    }
}

- (void)sendSubviewToBack:(UIView *)view
{
    if (view.superview == self) {
        [_layer insertSublayer:view.layer atIndex:0];
    }
}

- (BOOL)isDescendantOfView:(UIView *)view
{
    if (view) {
        UIView *testView = self;
        while (testView) {
            if (testView == view) {
                return YES;
            } else {
                testView = testView.superview;
            }
        }
    }
    return NO;
}

- (UIView *)viewWithTag:(NSInteger)tag
{
    UIView *foundView = nil;
    
    if (self.tag == tag) {
        foundView = self;
    } else {
        for (UIView *view in [self.subviews reverseObjectEnumerator]) {
            foundView = [view viewWithTag:tag];
            if (foundView)
                break;
        }
    }
    
    return foundView;
}

- (void)setNeedsLayout
{
    [_layer setNeedsLayout];
}

- (void)layoutIfNeeded
{
    [_layer layoutIfNeeded];
}

- (void)_layoutSubviews
{
//    [self _updateAppearanceIfNeeded];
    [[self _viewController] viewWillLayoutSubviews];
    [self layoutSubviews];
    [[self _viewController] viewDidLayoutSubviews];
}

#pragma mark Overriding point
- (void)layoutSubviews
{
}

- (void)didAddSubview:(UIView *)subview
{
}

- (void)willRemoveSubview:(UIView *)subview
{
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
}

- (void)didMoveToSuperview
{
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
}

- (void)didMoveToWindow
{
}
@end

@implementation UIView (UIViewRendering)

- (void)setContentMode:(UIViewContentMode)mode
{
    if (mode != _contentMode) {
        _contentMode = mode;
        switch(_contentMode) {
            case UIViewContentModeScaleToFill:
                _layer.contentsGravity = kCAGravityResize;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeScaleAspectFit:
                _layer.contentsGravity = kCAGravityResizeAspect;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeScaleAspectFill:
                _layer.contentsGravity = kCAGravityResizeAspectFill;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeRedraw:
                _layer.needsDisplayOnBoundsChange = YES;
                break;
                
            case UIViewContentModeCenter:
                _layer.contentsGravity = kCAGravityCenter;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeTop:
                _layer.contentsGravity = kCAGravityTop;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeBottom:
                _layer.contentsGravity = kCAGravityBottom;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeLeft:
                _layer.contentsGravity = kCAGravityLeft;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeRight:
                _layer.contentsGravity = kCAGravityRight;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeTopLeft:
                _layer.contentsGravity = kCAGravityTopLeft;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeTopRight:
                _layer.contentsGravity = kCAGravityTopRight;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeBottomLeft:
                _layer.contentsGravity = kCAGravityBottomLeft;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
                
            case UIViewContentModeBottomRight:
                _layer.contentsGravity = kCAGravityBottomRight;
                _layer.needsDisplayOnBoundsChange = NO;
                break;
        }
    }
}


- (UIViewContentMode)contentMode
{
    return _contentMode;
}

- (void)setContentStretch:(CGRect)contentStretch
{
    NS_UNIMPLEMENTED_LOG;
}


- (CGRect)contentStretch
{
    NS_UNIMPLEMENTED_LOG;
    return CGRectZero;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        [self setNeedsDisplay];
    }
}

- (UIColor *)backgroundColor
{
    return _backgroundColor;
}

- (id<CAAction>) actionForLayer: (CALayer*)layer forKey: (NSString*)eventKey
{
    // FIX: create a class _UIViewAnimatingLayerDelegate
    if (_animationsEnabled && [_animationGroups lastObject] && layer == _layer) {
        return [[_animationGroups lastObject] actionForView:self forKey:eventKey] ?: (id)[NSNull null];
    }
    return [NSNull null];
}

- (void)displayLayer:(CALayer *)theLayer
{
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    CGContextTranslateCTM(ctx, theLayer.frame.origin.x, theLayer.frame.origin.y);
//    
//    if (theLayer.backgroundColor) {
//        CGContextSetFillColorWithColor(ctx, theLayer.backgroundColor);
//        CGContextFillRect(ctx, theLayer.frame);
//    }
//    
//    for (UIView *subView in _subviews) {
//        NSLog(@"draw layer:%@",subView.layer);
//        if (subView.layer.needsDisplay) {
//            CGContextSaveGState(ctx);
//            [subView.layer displayIfNeeded];
//            CGContextRestoreGState(ctx);
//            
//            if (subView.layer.contents) {
//                NSLog(@"draw layer contnts.");
//                CGContextDrawImage(ctx, subView.layer.frame, subView.layer.contents);
//            }
//        }
//        
//    }
    theLayer.backgroundColor = self.backgroundColor.CGColor;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    // We only get here if the UIView subclass implements drawRect:. To do this without a drawRect: is a huge waste of memory.
    const CGRect bounds = CGContextGetClipBoundingBox(ctx);
    UIGraphicsPushContext(ctx);
    CGContextSaveGState(ctx);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -layer.bounds.size.height);
    [self drawRect:layer.bounds];
    CGContextRestoreGState(ctx);
    UIGraphicsPopContext();
}

- (void)drawRect:(CGRect)rect
{
    
}

- (void)setNeedsDisplay
{
    [_layer setNeedsDisplay];
}

- (void)setNeedsDisplayInRect:(CGRect)rect
{
    [_layer setNeedsDisplayInRect:rect];
}

- (BOOL)clipsToBounds
{
    return _layer.masksToBounds;
}

- (void)setClipsToBounds:(BOOL)flag
{
    _layer.masksToBounds = flag;
}

- (CGFloat)alpha
{
    return _layer.opacity;
}

- (void)setAlpha:(CGFloat)anAlpha
{
    _layer.opacity = anAlpha;
}

- (BOOL)isOpaque
{
    return _layer.opaque;
}

- (void)setOpaque:(BOOL)flag
{
    _layer.opaque = flag;
}

- (BOOL)clearsContextBeforeDrawing
{
    return _clearsContextBeforeDrawing;
}

- (void)setClearsContextBeforeDrawing:(BOOL)flag
{
    if (_clearsContextBeforeDrawing != flag) {
        _clearsContextBeforeDrawing = flag;
    }
}
- (BOOL)isHidden
{
    return _layer.hidden;
}

- (void)setHidden:(BOOL)flag
{
    _layer.hidden = flag;
//    [[NSNotificationCenter defaultCenter] postNotificationName:UIViewHiddenDidChangeNotification object:self];
}

#pragma mark iOS 7
- (void)setTintAdjustmentMode:(UIViewTintAdjustmentMode)tintAdjustmentMode
{
    NS_UNIMPLEMENTED_LOG;
}

- (UIViewTintAdjustmentMode)tintAdjustmentMode
{
    NS_UNIMPLEMENTED_LOG;
    return UIViewTintAdjustmentModeAutomatic;
}

- (void)setTintColor:(UIColor *)tintColor
{
    NS_UNIMPLEMENTED_LOG;
}

- (UIColor *)tintColor
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)tintColorDidChange
{
    NS_UNIMPLEMENTED_LOG;
}

@end

@implementation UIView (UIViewAnimation)

+ (void)initialize
{
    if (self == [UIView class]) {
        _animationGroups = [[NSMutableArray alloc] init];
    }
}

+ (void)beginAnimations:(NSString *)animationID context:(void *)context
{
    [_animationGroups addObject:[UIViewAnimationGroup animationGroupWithName:animationID context:context]];
}

+ (void)commitAnimations
{
    if ([_animationGroups count] > 0) {
        UIViewAnimationGroup *group = [_animationGroups lastObject];
        [_animationGroups removeLastObject];
        [group commit];
    }
}

+ (void)setAnimationDelegate:(id)delegate
{
    [[_animationGroups lastObject] setAnimationDelegate:delegate];
}

+ (void)setAnimationWillStartSelector:(SEL)selector
{
    [[_animationGroups lastObject] setAnimationWillStartSelector:selector];
}

+ (void)setAnimationDidStopSelector:(SEL)selector
{
    [[_animationGroups lastObject] setAnimationDidStopSelector:selector];
}

+ (void)setAnimationDuration:(NSTimeInterval)duration
{
    [[_animationGroups lastObject] setAnimationDuration:duration];
}

+ (void)setAnimationDelay:(NSTimeInterval)delay
{
    [[_animationGroups lastObject] setAnimationDelay:delay];
}

+ (void)setAnimationStartDate:(NSDate *)startDate
{
    NS_UNIMPLEMENTED_LOG;
}

+ (void)setAnimationCurve:(UIViewAnimationCurve)curve
{
    [[_animationGroups lastObject] setAnimationCurve:curve];
}

+ (void)setAnimationRepeatCount:(float)repeatCount
{
    [[_animationGroups lastObject] setAnimationRepeatCount:repeatCount];
}

+ (void)setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses
{
    [[_animationGroups lastObject] setAnimationRepeatAutoreverses:repeatAutoreverses];
}

+ (void)setAnimationBeginsFromCurrentState:(BOOL)fromCurrentState
{
    [[_animationGroups lastObject] setAnimationBeginsFromCurrentState:fromCurrentState];
}

+ (void)setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache
{
    [[_animationGroups lastObject] setAnimationTransition:transition forView:view cache:cache];
}

+ (void)setAnimationsEnabled:(BOOL)enabled
{
    _animationsEnabled = enabled;
}

+ (BOOL)areAnimationsEnabled
{
    return _animationsEnabled;
}

+ (void)performWithoutAnimation:(void (^)(void))actionsWithoutAnimation
{
    NS_UNIMPLEMENTED_LOG;
}
@end

@implementation UIView (UIViewAnimationWithBlocks)
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    const BOOL ignoreInteractionEvents = !((options & UIViewAnimationOptionAllowUserInteraction) == UIViewAnimationOptionAllowUserInteraction);
    const BOOL repeatAnimation = ((options & UIViewAnimationOptionRepeat) == UIViewAnimationOptionRepeat);
    const BOOL autoreverseRepeat = ((options & UIViewAnimationOptionAutoreverse) == UIViewAnimationOptionAutoreverse);
    const BOOL beginFromCurrentState = ((options & UIViewAnimationOptionBeginFromCurrentState) == UIViewAnimationOptionBeginFromCurrentState);
    UIViewAnimationCurve animationCurve;
    
    if ((options & UIViewAnimationOptionCurveEaseInOut) == UIViewAnimationOptionCurveEaseInOut) {
        animationCurve = UIViewAnimationCurveEaseInOut;
    } else if ((options & UIViewAnimationOptionCurveEaseIn) == UIViewAnimationOptionCurveEaseIn) {
        animationCurve = UIViewAnimationCurveEaseIn;
    } else if ((options & UIViewAnimationOptionCurveEaseOut) == UIViewAnimationOptionCurveEaseOut) {
        animationCurve = UIViewAnimationCurveEaseOut;
    } else {
        animationCurve = UIViewAnimationCurveLinear;
    }
    
    // NOTE: As of iOS 5 this is only supposed to block interaction events for the views being animated, not the whole app.
    if (ignoreInteractionEvents) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    UIViewBlockAnimationDelegate *delegate = [[UIViewBlockAnimationDelegate alloc] init];
    delegate.completion = completion;
    delegate.ignoreInteractionEvents = ignoreInteractionEvents;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDelay:delay];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationBeginsFromCurrentState:beginFromCurrentState];
    [UIView setAnimationDelegate:delegate];	// this is retained here
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    [UIView setAnimationRepeatCount:(repeatAnimation? FLT_MAX : 0)];
    [UIView setAnimationRepeatAutoreverses:autoreverseRepeat];
    
    animations();
    
    [UIView commitAnimations];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [self animateWithDuration:duration
                        delay:0
                      options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                   animations:animations
                   completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations
{
    [self animateWithDuration:duration animations:animations completion:NULL];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    NS_UNIMPLEMENTED_LOG;
}

+ (void)transitionWithView:(UIView *)view duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    NS_UNIMPLEMENTED_LOG;
    //FIXME: Needs Imp
    NSLog(@"call async");
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"in transition async");
        if (completion) {
            NSLog(@"call completion");
            completion(YES);
        }
    }];
//    dispatch_async(dispatch_get_main_queue(), ^{
//    });
}

+ (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion
{
    NS_UNIMPLEMENTED_LOG;
    //FIXME: Needs Imp
    NSLog(@"call async");
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"in transition async");
        if (completion) {
            NSLog(@"call completion");
            completion(YES);
        }
    }];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//    });
}

+ (void)performSystemAnimation:(UISystemAnimation)animation onViews:(NSArray *)views options:(UIViewAnimationOptions)options animations:(void (^)(void))parallelAnimations completion:(void (^)(BOOL finished))completion
{
    NS_UNIMPLEMENTED_LOG;
}
@end

@implementation UIView (UIViewKeyframeAnimations)

+ (void)animateKeyframesWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewKeyframeAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    NS_UNIMPLEMENTED_LOG;
}

+ (void)addKeyframeWithRelativeStartTime:(double)frameStartTime relativeDuration:(double)frameDuration animations:(void (^)(void))animations
{
    NS_UNIMPLEMENTED_LOG;
}

@end

@implementation UIView (UIViewGestureRecognizers)

- (void)setGestureRecognizers:(NSArray *)gestureRecognizers
{
    for (UIGestureRecognizer *gesture in [_gestureRecognizers allObjects]) {
        [self removeGestureRecognizer:gesture];
    }
    
    for (UIGestureRecognizer *gesture in gestureRecognizers) {
        [self addGestureRecognizer:gesture];
    }
}

- (NSArray *)gestureRecognizers
{
    return [_gestureRecognizers allObjects];
}

- (void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    if (![_gestureRecognizers containsObject:gestureRecognizer]) {
        [gestureRecognizer.view removeGestureRecognizer:gestureRecognizer];
        [_gestureRecognizers addObject:gestureRecognizer];
        [gestureRecognizer _setView:self];
    }
}

- (void)removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    if ([_gestureRecognizers containsObject:gestureRecognizer]) {
        [gestureRecognizer _setView:nil];
        [_gestureRecognizers removeObject:gestureRecognizer];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //FIXME: 
    return YES;
}

@end
