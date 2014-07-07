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

#import "UINavigationBar.h"
#import "UINavigationBar+UIPrivate.h"
#import "UIGraphics.h"
#import "UIColor.h"
#import "UILabel.h"
#import "UIFont.h"
#import "UIImage+UIPrivate.h"
#import "UIBarButtonItem.h"
#import "UIButton.h"

#import <dispatch/dispatch.h>

@interface UINavigationItem (UIPrivate)
- (void)_setNavigationBar:(UINavigationBar *)navigationBar;
- (UINavigationBar *)_navigationBar;
@end

static const UIEdgeInsets kButtonEdgeInsets = {0,0,0,0};
static const CGFloat kMinButtonWidth = 30;
static const CGFloat kMaxButtonWidth = 200;
static const CGFloat kMaxButtonHeight = 96;//24;
static const CGFloat kDefaultButtonsGap = 8;
static const CGFloat kDefaultBackButtonsFontSize = 22; //11
static const CGFloat kDefaultTitleFontSize = 28; //14

static const NSTimeInterval kAnimationDuration = 0.33;

typedef enum {
    _UINavigationBarTransitionPush,
    _UINavigationBarTransitionPop,
    _UINavigationBarTransitionReload		// explicitly tag reloads from changed UINavigationItem data
} _UINavigationBarTransition;

@implementation UINavigationBar
{
    NSMutableArray *_navStack;

    UIView *_leftView;
    UIView *_centerView;
    UIView *_rightView;
    
    struct {
        unsigned shouldPushItem : 1;
        unsigned didPushItem : 1;
        unsigned shouldPopItem : 1;
        unsigned didPopItem : 1;
    } _delegateHas;
    
    // ideally this should share the same memory as the above flags structure...
    struct {
        unsigned reloadItem : 1;
        unsigned __RESERVED__ : 31;
    } _navigationBarFlags;
}
@synthesize barPosition = _barPosition;


+ (void)_setBarButtonSize:(UIView *)view
{
    CGRect frame = view.frame;
    frame.size = [view sizeThatFits:CGSizeMake(kMaxButtonWidth,kMaxButtonHeight)];
    frame.size.height = kMaxButtonHeight;
    frame.size.width = MAX(frame.size.width,kMinButtonWidth);
    view.frame = frame;
}

+ (UIButton *)_backButtonWithBarButtonItem:(UIBarButtonItem *)item
{
    if (!item) return nil;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage _backButtonImage] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage _highlightedBackButtonImage] forState:UIControlStateHighlighted];
    [backButton setTitle:item.title forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:kDefaultBackButtonsFontSize];
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0,15,0,7);
    [backButton addTarget:nil action:@selector(_backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self _setBarButtonSize:backButton];
    return backButton;
}

+ (UIView *)_viewWithBarButtonItem:(UIBarButtonItem *)item
{
    if (!item) return nil;
    
    if (item.customView) {
        [self _setBarButtonSize:item.customView];
        return item.customView;
    } else {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage _toolbarButtonImage] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage _highlightedToolbarButtonImage] forState:UIControlStateHighlighted];
        [button setTitle:item.title forState:UIControlStateNormal];
        [button setImage:item.image forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:kDefaultBackButtonsFontSize];
        button.contentEdgeInsets = UIEdgeInsetsMake(0,7,0,7);
        [button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
        [self _setBarButtonSize:button];
        return button;
    }
}

+ (UIView *)_viewWithBarButtonItems:(NSArray *)items
{
    if (!items || items.count == 0) {
        return nil;
    }
    
    NSMutableArray *subviews = [NSMutableArray array];
    
    CGFloat width = 0;
    CGFloat xOffset = 0;
    for (UIBarButtonItem *item in items) {
        UIView *view = [self _viewWithBarButtonItem:item];
        CGRect frame = view.frame;
        frame.origin.x = xOffset;
        view.frame = frame;
        
        xOffset += view.frame.size.width + kDefaultButtonsGap;
        width += view.frame.size.width + kDefaultButtonsGap;
        [subviews addObject:view];
    }
    
    UIView *lastItemView = [subviews lastObject];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, lastItemView.frame.size.height)];
    
    for (UIView *subView in subviews) {
        [view addSubview:subView];
    }
    
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _navStack = [[NSMutableArray alloc] init];
        self.tintColor = [UIColor colorWithRed:21/255.f green:21/255.f blue:25/255.f alpha:1];
    }
    return self;
}

- (void)dealloc
{
    [self.topItem _setNavigationBar: nil];
}

- (void)setDelegate:(id)newDelegate
{
    _delegate = newDelegate;
    
    _delegateHas.shouldPushItem = [_delegate respondsToSelector:@selector(navigationBar:shouldPushItem:)];
    _delegateHas.didPushItem = [_delegate respondsToSelector:@selector(navigationBar:didPushItem:)];
    _delegateHas.shouldPopItem = [_delegate respondsToSelector:@selector(navigationBar:shouldPopItem:)];
    _delegateHas.didPopItem = [_delegate respondsToSelector:@selector(navigationBar:didPopItem:)];
}

- (UINavigationItem *)topItem
{
    return [_navStack lastObject];
}

- (UINavigationItem *)backItem
{
    return ([_navStack count] <= 1)? nil : [_navStack objectAtIndex:[_navStack count]-2];
}

- (void)_backButtonTapped:(id)sender
{
    [self popNavigationItemAnimated:YES];
}

- (void)_removeAnimatedViews:(NSArray *)views
{
    [views makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)_setViewsWithTransition:(_UINavigationBarTransition)transition animated:(BOOL)animated
{
    {
        NSMutableArray *previousViews = [[NSMutableArray alloc] init];
        
        if (_leftView) [previousViews addObject:_leftView];
        if (_centerView) [previousViews addObject:_centerView];
        if (_rightView) [previousViews addObject:_rightView];
        
        if (animated) {
            CGFloat moveCenterBy = self.bounds.size.width - ((_centerView)? _centerView.frame.origin.x : 0);
            CGFloat moveLeftBy = self.bounds.size.width * 0.33f;
            
            if (transition == _UINavigationBarTransitionPush) {
                moveCenterBy *= -1.f;
                moveLeftBy *= -1.f;
            }
            
            [UIView animateWithDuration:kAnimationDuration
                             animations:^(void) {
                                 if (_leftView)     _leftView.frame = CGRectOffset(_leftView.frame, moveLeftBy, 0);
                                 if (_centerView)   _centerView.frame = CGRectOffset(_centerView.frame, moveCenterBy, 0);
                             }];
            
            [UIView animateWithDuration:kAnimationDuration * 0.8
                                  delay:kAnimationDuration * 0.2
                                options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                             animations:^(void) {
                                 _leftView.alpha = 0;
                                 _rightView.alpha = 0;
                                 _centerView.alpha = 0;
                             }
                             completion:NULL];
            
            [self performSelector:@selector(_removeAnimatedViews:) withObject:previousViews afterDelay:kAnimationDuration];
        } else {
            [self _removeAnimatedViews:previousViews];
        }
        
    }
    
    UINavigationItem *topItem = self.topItem;
    
    if (topItem) {
        UINavigationItem *backItem = self.backItem;
        
        // update weak references
        [backItem _setNavigationBar: nil];
        [topItem _setNavigationBar: self];
        
        CGRect leftFrame = CGRectZero;
        CGRect rightFrame = CGRectZero;
        
        if (backItem) {
            _leftView = [[self class] _backButtonWithBarButtonItem:backItem.backBarButtonItem];
        } else {
            _leftView = [[self class] _viewWithBarButtonItems:topItem.leftBarButtonItems];
        }
        
        if (_leftView) {
            leftFrame = _leftView.frame;
            leftFrame.origin = CGPointMake(kButtonEdgeInsets.left, kButtonEdgeInsets.top);
            _leftView.frame = leftFrame;
            [self addSubview:_leftView];
        }
        
        _rightView = [[self class] _viewWithBarButtonItems:topItem.rightBarButtonItems];
        
        if (_rightView) {
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            rightFrame = _rightView.frame;
            rightFrame.origin.x = self.bounds.size.width-rightFrame.size.width - kButtonEdgeInsets.right;
            rightFrame.origin.y = kButtonEdgeInsets.top;
            _rightView.frame = rightFrame;
            [self addSubview:_rightView];
        }
        
        _centerView = topItem.titleView;
        
        if (!_centerView) {
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.text = topItem.title;
            titleLabel.textAlignment = UITextAlignmentCenter;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont boldSystemFontOfSize:kDefaultTitleFontSize];
            _centerView = titleLabel;
        }
        
        const CGFloat centerPadding = MAX(leftFrame.size.width, rightFrame.size.width);
        _centerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _centerView.frame = CGRectMake(kButtonEdgeInsets.left+centerPadding,kButtonEdgeInsets.top,self.bounds.size.width-kButtonEdgeInsets.right-kButtonEdgeInsets.left-centerPadding-centerPadding,kMaxButtonHeight);
        [self addSubview:_centerView];
        
        if (animated) {
            CGFloat moveCenterBy = self.bounds.size.width - ((_centerView)? _centerView.frame.origin.x : 0);
            CGFloat moveLeftBy = self.bounds.size.width * 0.33f;
            
            if (transition == _UINavigationBarTransitionPush) {
                moveLeftBy *= -1.f;
                moveCenterBy *= -1.f;
            }
            
            CGRect destinationLeftFrame = _leftView? _leftView.frame : CGRectZero;
            CGRect destinationCenterFrame = _centerView? _centerView.frame : CGRectZero;
            
            if (_leftView)      _leftView.frame = CGRectOffset(_leftView.frame, -moveLeftBy, 0);
            if (_centerView)    _centerView.frame = CGRectOffset(_centerView.frame, -moveCenterBy, 0);
            
            _leftView.alpha = 0;
            _rightView.alpha = 0;
            _centerView.alpha = 0;
            
            [UIView animateWithDuration:kAnimationDuration
                             animations:^(void) {
                                 _leftView.frame = destinationLeftFrame;
                                 _centerView.frame = destinationCenterFrame;
                             }];
            
            [UIView animateWithDuration:kAnimationDuration * 0.8
                                  delay:kAnimationDuration * 0.2
                                options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                             animations:^(void) {
                                 _leftView.alpha = 1;
                                 _rightView.alpha = 1;
                                 _centerView.alpha = 1;
                             }
                             completion:NULL];
        }
    } else {
        _leftView = _centerView = _rightView = nil;
    }
}

- (void)setTintColor:(UIColor *)newColor
{
    if (newColor != _tintColor) {
        _tintColor = newColor;
        [self setNeedsDisplay];
    }
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    if (![_navStack isEqualToArray:items]) {
        [_navStack removeAllObjects];
        [_navStack addObjectsFromArray:items];
        [self _setViewsWithTransition:_UINavigationBarTransitionPush animated:animated];
    }
}

- (void)setItems:(NSArray *)items
{
    [self setItems:items animated:NO];
}

- (UIBarStyle)barStyle
{
    NS_UNIMPLEMENTED_LOG;
    return UIBarStyleDefault;
}

- (void)setBarStyle:(UIBarStyle)barStyle
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)pushNavigationItem:(UINavigationItem *)item animated:(BOOL)animated
{
    BOOL shouldPush = YES;
    
    if (_delegateHas.shouldPushItem) {
        shouldPush = [_delegate navigationBar:self shouldPushItem:item];
    }
    
    if (shouldPush) {
        [_navStack addObject:item];
        [self _setViewsWithTransition:_UINavigationBarTransitionPush animated:animated];
        
        if (_delegateHas.didPushItem) {
            [_delegate navigationBar:self didPushItem:item];
        }
    }
}

- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated
{
    UINavigationItem *previousItem = self.topItem;
    
    if (previousItem) {
        BOOL shouldPop = YES;
        
        if (_delegateHas.shouldPopItem) {
            shouldPop = [_delegate navigationBar:self shouldPopItem:previousItem];
        }
        
        if (shouldPop) {
            [_navStack removeObject:previousItem];
            [self _setViewsWithTransition:_UINavigationBarTransitionPop animated:animated];
            
            if (_delegateHas.didPopItem) {
                [_delegate navigationBar:self didPopItem:previousItem];
            }
            
            return previousItem;
        }
    }
    
    return nil;
}

- (void)_updateNavigationItem:(UINavigationItem *)item animated:(BOOL)animated	// ignored for now
{
    // let's sanity-check that the item is supposed to be talking to us
    if (item != self.topItem) {
        [item _setNavigationBar:nil];
        return;
    }
    
    // this is going to remove & re-add all the item views. Not ideal, but simple enough that it's worth profiling.
    // next step is to add animation support-- that will require changing _setViewsWithTransition:animated:
    //  such that it won't perform any coordinate translations, only fade in/out
    
    // don't just fire the damned thing-- set a flag & mark as needing layout
    if (_navigationBarFlags.reloadItem == 0) {
        _navigationBarFlags.reloadItem = 1;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_navigationBarFlags.reloadItem) {
        _navigationBarFlags.reloadItem = 0;
        [self _setViewsWithTransition:_UINavigationBarTransitionReload animated:NO];
    }
}

- (void)drawRect:(CGRect)rect
{
    const CGRect bounds = self.bounds;
    
    // I kind of suspect that the "right" thing to do is to draw the background and then paint over it with the tintColor doing some kind of blending
    // so that it actually doesn "tint" the image instead of define it. That'd probably work better with the bottom line coloring and stuff, too, but
    // for now hardcoding stuff works well enough.
    
    [_tintColor setFill];
    UIRectFill(bounds);
    
    // FIXME: should correct draw background
    [[UIColor whiteColor] setFill];
    UIRectFill(bounds);
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
}

- (UIImage *)backgroundImageForBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (UIImage *)backgroundImageForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)setTitleVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
}

- (CGFloat)titleVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return 0.0f;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NS_UNIMPLEMENTED_LOG;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        NS_UNIMPLEMENTED_LOG;
    }
    return self;
}
@end

static void * const UINavigationItemContext = "UINavigationItemContext";

@implementation UINavigationItem {
    UINavigationBar *_navigationBar;
}

+ (NSSet *)_keyPathsTriggeringUIUpdates
{
    static NSSet * __keyPaths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __keyPaths = [[NSSet alloc] initWithObjects:@"title", @"prompt", @"backBarButtonItem", @"leftBarButtonItem", @"rightBarButtonItem",@"leftBarButtonItems", @"rightBarButtonItems", @"titleView", @"hidesBackButton", nil];
    });
    return __keyPaths;
}

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _title = title;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != UINavigationItemContext) {
        if ([[self superclass] instancesRespondToSelector:_cmd])
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    [[self _navigationBar] _updateNavigationItem:self animated:NO];
}

- (void)_setNavigationBar:(UINavigationBar *)navigationBar
{
    // weak reference
    if (_navigationBar == navigationBar)
        return;
    
    if (_navigationBar != nil && navigationBar == nil) {
        // remove observation
        for (NSString * keyPath in [[self class] _keyPathsTriggeringUIUpdates]) {
            [self removeObserver:self forKeyPath:keyPath];
        }
    }
    else if (navigationBar != nil) {
        // observe property changes to notify UI element
        for (NSString * keyPath in [[self class] _keyPathsTriggeringUIUpdates]) {
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:UINavigationItemContext];
        }
    }
    
    _navigationBar = navigationBar;
}

- (UINavigationBar *)_navigationBar
{
    return _navigationBar;
}

- (UIBarButtonItem *)leftBarButtonItem
{
    if (self.leftBarButtonItems.count == 0) {
        return nil;
    }
    return [self.leftBarButtonItems objectAtIndex:0];
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    [self setLeftBarButtonItems:@[item] animated:animated];
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)item
{
    [self setLeftBarButtonItem:item animated:NO];
}

- (UIBarButtonItem *)rightBarButtonItem
{
    if (self.rightBarButtonItems.count == 0) {
        return nil;
    }
    return [self.rightBarButtonItems objectAtIndex:0];
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    [self setRightBarButtonItems:@[item] animated:animated];
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)item
{
    [self setRightBarButtonItem:item animated:NO];
}

- (void)setRightBarButtonItems:(NSArray *)items animated:(BOOL)animated
{
    if (items != _rightBarButtonItems) {
        [self willChangeValueForKey:@"rightBarButtonItems"];
        _rightBarButtonItems = items;
        [self didChangeValueForKey:@"rightBarButtonItems"];
    }
}

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems
{
    [self setRightBarButtonItems:rightBarButtonItems animated:NO];
}

- (void)setLeftBarButtonItems:(NSArray *)items animated:(BOOL)animated
{
    if (items != _leftBarButtonItems) {
        [self willChangeValueForKey:@"leftBarButtonItems"];
        _leftBarButtonItems = items;
        [self didChangeValueForKey:@"leftBarButtonItems"];
    }
}

- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems
{
    [self setLeftBarButtonItems:leftBarButtonItems animated:NO];
}

- (void)setHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated
{
    [self willChangeValueForKey: @"hidesBackButton"];
    _hidesBackButton = hidesBackButton;
    [self didChangeValueForKey: @"hidesBackButton"];
}

- (void)setHidesBackButton:(BOOL)hidesBackButton
{
    [self setHidesBackButton:hidesBackButton animated:NO];
}

- (UIBarButtonItem *)backBarButtonItem
{
    if (_backBarButtonItem) {
        return _backBarButtonItem;
    } else {
        return [[UIBarButtonItem alloc] initWithTitle:(self.title ?: @"Back") style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NS_UNIMPLEMENTED_LOG;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NS_UNIMPLEMENTED_LOG;
    self = [super init];
    return self;
}
@end
