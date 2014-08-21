//
//  UINavigationController.m
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UINavigationController.h"
#import "UINavigationBar.h"
#import "UIToolbar.h"
#import "UIScrollView.h"

static const NSTimeInterval kAnimationDuration = 0.33;
static const CGFloat NavBarHeight = 112;//28;
static const CGFloat ToolbarHeight = 28;

typedef enum {
	_UINavigationControllerVisibleControllerTransitionNone = 0,
	_UINavigationControllerVisibleControllerTransitionPushAnimated,
	_UINavigationControllerVisibleControllerTransitionPopAnimated
} _UINavigationControllerVisibleControllerTransition;

@interface UINavigationController ()

@end

@implementation UINavigationController {
    BOOL _toolbarHidden;
    BOOL _navigationBarHidden;
    NSMutableArray *_viewControllers;

    struct {
        unsigned didShowViewController : 1;
        unsigned willShowViewController : 1;
    } _delegateHas;
    
    BOOL _visibleViewControllerNeedsUpdate;
    _UINavigationControllerVisibleControllerTransition _visibleViewControllerTransition;

}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewControllers = [[NSMutableArray alloc] initWithCapacity:1];
        _navigationBar = [[navigationBarClass alloc] init];
        _navigationBar.delegate = self;
        _toolbar = [[toolbarClass alloc] init];
        _toolbarHidden = YES;

    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [self initWithNavigationBarClass:[UINavigationBar class] toolbarClass:[UIToolbar class]];
    if (self) {
        [self pushViewController:rootViewController animated:NO];
    }
    return self;
    
}

#pragma mark -

- (void)setDelegate:(id<UINavigationControllerDelegate>)newDelegate
{
    _delegate = newDelegate;
    _delegateHas.didShowViewController = [_delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)];
    _delegateHas.willShowViewController = [_delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)];
}

- (CGRect)_navigationBarFrame
{
    CGRect navBarFrame = self.view.bounds;
    navBarFrame.size.height = NavBarHeight;
    return navBarFrame;
}

- (CGRect)_toolbarFrame
{
    CGRect toolbarRect = self.view.bounds;
    toolbarRect.origin.y = toolbarRect.origin.y + toolbarRect.size.height - ToolbarHeight;
    toolbarRect.size.height = ToolbarHeight;
    return toolbarRect;
}

- (CGRect)_controllerFrameForTransition:(_UINavigationControllerVisibleControllerTransition)transition
{
    CGRect controllerFrame = self.view.bounds;
    NSLog(@"%s: navi bounds: %@",__PRETTY_FUNCTION__,NSStringFromCGRect(controllerFrame));

    // adjust for the nav bar
    if (!self.navigationBarHidden &&
        ![self _isNavigationBarTranslucent]) {
        controllerFrame.origin.y += NavBarHeight;
        controllerFrame.size.height -= NavBarHeight;
    }
    
    // adjust for toolbar (if there is one)
    if (!self.toolbarHidden) {
        controllerFrame.size.height -= ToolbarHeight;
    }
    
    if (transition == _UINavigationControllerVisibleControllerTransitionPushAnimated) {
        controllerFrame = CGRectOffset(controllerFrame, controllerFrame.size.width, 0);
    } else if (transition == _UINavigationControllerVisibleControllerTransitionPopAnimated) {
        controllerFrame = CGRectOffset(controllerFrame, -controllerFrame.size.width, 0);
    }
    
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,NSStringFromCGRect(controllerFrame));
    return controllerFrame;
}

- (void)_setVisibleViewControllerNeedsUpdate
{
    NSLog(@"[%@] %s",NSStringFromClass([self class]),__PRETTY_FUNCTION__);
	// schedules a deferred method to run
	if (!_visibleViewControllerNeedsUpdate) {
		_visibleViewControllerNeedsUpdate = YES;
		[self performSelector:@selector(_updateVisibleViewController) withObject:nil afterDelay:0];
	}
}

- (void)_adjustScrollViewInsetsIfNeeds:(UIViewController *)viewController
{
    if (viewController.automaticallyAdjustsScrollViewInsets) {
        UIScrollView *viewToAdjust = nil;
        if ([viewController.view isKindOfClass:[UIScrollView class]]) {
            viewToAdjust = (UIScrollView *)viewController.view;
        }
        
        if (!viewToAdjust && viewController.view.subviews.count > 0) {
            UIView *firstSubView = viewController.view.subviews[0];
            if ([firstSubView isKindOfClass:[UIScrollView class]]) {
                viewToAdjust = (UIScrollView *)firstSubView;
            }
        }
        
        viewToAdjust.contentInset = UIEdgeInsetsMake(NavBarHeight, 0, 0, 0);
    }
}

- (void)_updateVisibleViewController
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
	// do some bookkeeping
	_visibleViewControllerNeedsUpdate = NO;
    UIViewController *topViewController = self.topViewController;
    NSLog(@"topViewController:%@",topViewController);
    
	// make sure the new top view is both loaded and set to appear in the correct place
	topViewController.view.frame = [self _controllerFrameForTransition:_visibleViewControllerTransition];
    topViewController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSLog(@"set topViewController frame:%@",NSStringFromCGRect(topViewController.view.frame));
    
	if (_visibleViewControllerTransition == _UINavigationControllerVisibleControllerTransitionNone) {
        NSLog(@"_UINavigationControllerVisibleControllerTransitionNone");
		[_visibleViewController viewWillDisappear:NO];
		[topViewController viewWillAppear:NO];
        
        if (_delegateHas.willShowViewController) {
            [_delegate navigationController:self willShowViewController:topViewController animated:NO];
        }
        
		[_visibleViewController.view removeFromSuperview];
		[self.view insertSubview:topViewController.view atIndex:0];
        
        [self _adjustScrollViewInsetsIfNeeds:topViewController];
        
		[_visibleViewController viewDidDisappear:NO];
		[topViewController viewDidAppear:NO];
        
        if (_delegateHas.didShowViewController) {
            [_delegate navigationController:self didShowViewController:topViewController animated:NO];
        }
    } else {
        const CGRect visibleControllerFrame = (_visibleViewControllerTransition == _UINavigationControllerVisibleControllerTransitionPushAnimated)
        ? [self _controllerFrameForTransition:_UINavigationControllerVisibleControllerTransitionPopAnimated]
        : [self _controllerFrameForTransition:_UINavigationControllerVisibleControllerTransitionPushAnimated];
        
        const CGRect topControllerFrame = [self _controllerFrameForTransition:_UINavigationControllerVisibleControllerTransitionNone];
        
        UIViewController *previouslyVisibleViewController = _visibleViewController;
        
        [UIView animateWithDuration:kAnimationDuration
                         animations:^(void) {
                             previouslyVisibleViewController.view.frame = visibleControllerFrame;
                             topViewController.view.frame = topControllerFrame;
                             [self _adjustScrollViewInsetsIfNeeds:topViewController];
                         }
                         completion:^(BOOL finished) {
                             [previouslyVisibleViewController.view removeFromSuperview];
                             [previouslyVisibleViewController viewDidDisappear:YES];
                             [topViewController viewDidAppear:YES];
                             
                             if (_delegateHas.didShowViewController) {
                                 [_delegate navigationController:self didShowViewController:topViewController animated:YES];
                             }
                         }];
	}
    
    NSLog(@"set visible ViewController");
	_visibleViewController = topViewController;
}

- (BOOL)_isNavigationBarTranslucent
{
    return YES;
}

- (void)loadView
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    self.view.clipsToBounds = YES;
    
    UIViewController *viewController = self.visibleViewController;
    NSLog(@"visibleViewController:%@",viewController);
    
    viewController.view.frame = [self _controllerFrameForTransition:_UINavigationControllerVisibleControllerTransitionNone];
    NSLog(@"set frame:%@",NSStringFromCGRect(viewController.view.frame));
    
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:viewController.view];
    
    _navigationBar.frame = [self _navigationBarFrame];
    _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navigationBar.hidden = self.navigationBarHidden;
    [self.view addSubview:_navigationBar];
    
    _toolbar.frame = [self _toolbarFrame];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _toolbar.hidden = self.toolbarHidden;
    [self.view addSubview:_toolbar];
    
    self.view.backgroundColor = [UIColor blueColor];

}

- (void)viewDidLoad
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.topViewController.isViewLoaded) {
        [self _setVisibleViewControllerNeedsUpdate];
    }
    [self.visibleViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.visibleViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.visibleViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.visibleViewController viewDidDisappear:animated];
}


- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)newViewControllers animated:(BOOL)animated
{
    assert([newViewControllers count] >= 1);
    
    if (![newViewControllers isEqualToArray:_viewControllers]) {
        // remove them all in bulk
        [_viewControllers makeObjectsPerformSelector:@selector(_setParentViewController:) withObject:nil];
        [_viewControllers removeAllObjects];
        
        // reset the nav bar
        _navigationBar.items = nil;
        
        // add them back in one-by-one and only apply animation to the last one (if any)
        for (UIViewController *controller in newViewControllers) {
            [self pushViewController:controller animated:(animated && (controller == [newViewControllers lastObject]))];
        }
    }
}

- (UIViewController *)topViewController
{
    return [_viewControllers lastObject];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
//    assert(![viewController isKindOfClass:[UITabBarController class]]);
    assert(![_viewControllers containsObject:viewController]);
    
    // override the animated property based on current state
    animated = animated && _visibleViewController && self.view.window;
    
    // push on to controllers stack
    [_viewControllers addObject:viewController];
    [_navigationBar pushNavigationItem:viewController.navigationItem animated:animated];
    
    // take ownership responsibility
//    [viewController _setParentViewController:self];
    viewController->_parentViewController = self;
    
	// if animated and on screen, begin part of the transition immediately, specifically, get the new view
    // on screen asap and tell the new controller it's about to be made visible in an animated fashion
	if (animated) {
		_visibleViewControllerTransition = _UINavigationControllerVisibleControllerTransitionPushAnimated;
        
		viewController.view.frame = [self _controllerFrameForTransition:_visibleViewControllerTransition];
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
		[_visibleViewController viewWillDisappear:YES];
		[viewController viewWillAppear:YES];
        
        if (_delegateHas.willShowViewController) {
            [_delegate navigationController:self willShowViewController:viewController animated:YES];
        }
        
		[self.view insertSubview:viewController.view atIndex:0];
	}
    
    if (self.view.superview) {
        [self _setVisibleViewControllerNeedsUpdate];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    // don't allow popping the rootViewController
    if ([_viewControllers count] <= 1) {
        return nil;
    }
    
    UIViewController *formerTopViewController = self.topViewController;
    
    // adjust the animate property
    animated = animated && self.view.window;
    
	// pop the controller stack
    [_viewControllers removeLastObject];
    
    // pop the nav bar - note that it's setting the delegate to nil and back because we use the nav bar's
    // -navigationBar:shouldPopItem: delegate method to determine when the user clicks the back button
    // but that method is also called when we do an animated pop like this, so this works around the cycle.
    // I don't love it.
    _navigationBar.delegate = nil;
    [_navigationBar popNavigationItemAnimated:animated];
    _navigationBar.delegate = self;
    
    // give up ownership of the view controller
//    [formerTopViewController _setParentViewController:nil];
    formerTopViewController->_parentViewController = nil;
    
	// if animated, begin part of the transition immediately, specifically, get the new top view on screen asap
	// and tell the old visible controller it's about to be disappeared in an animated fashion
	if (animated && self.view.window) {
        // note the new top here so we don't have to use the accessor method all the time
        UIViewController *topController = self.topViewController;
        
		_visibleViewControllerTransition = _UINavigationControllerVisibleControllerTransitionPopAnimated;
        
		// if we never updated the visible controller, we need to add the formerTopViewController
		// on to the screen so we can see it disappear since we're attempting to animate this
		if (!_visibleViewController) {
			_visibleViewController = formerTopViewController;
			_visibleViewController.view.frame = [self _controllerFrameForTransition:_UINavigationControllerVisibleControllerTransitionNone];
			[self.view insertSubview:_visibleViewController.view atIndex:0];
		}
        
		topController.view.frame = [self _controllerFrameForTransition:_visibleViewControllerTransition];
        
		[_visibleViewController viewWillDisappear:YES];
		[topController viewWillAppear:YES];
        
        if (_delegateHas.willShowViewController) {
            [_delegate navigationController:self willShowViewController:topController animated:YES];
        }
        
		[self.view insertSubview:topController.view atIndex:0];
	}
    
    if (self.view.superview) {
        [self _setVisibleViewControllerNeedsUpdate];
    }
    
	return formerTopViewController;
}

- (NSArray *)childViewControllers
{
    return _viewControllers;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSMutableArray *popped = [[NSMutableArray alloc] init];
    
    if ([_viewControllers containsObject:viewController]) {
        while (self.topViewController != viewController) {
            UIViewController *poppedController = [self popViewControllerAnimated:animated];
            if (poppedController) {
                [popped addObject:poppedController];
            } else {
                break;
            }
        }
    }
    
    return popped;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:[_viewControllers objectAtIndex:0] animated:animated];
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    // always initiate an animated pop and return NO so that the nav bar itself doesn't take it upon itself
    // to pop the item, instead popViewControllerAnimated: will command it to do so later.
    [self popViewControllerAnimated:YES];
    return NO;
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    _toolbarHidden = hidden;
    _toolbar.hidden = hidden;
}

- (void)setToolbarHidden:(BOOL)hidden
{
    [self setToolbarHidden:hidden animated:NO];
}

- (BOOL)isToolbarHidden
{
    return _toolbarHidden || self.topViewController.hidesBottomBarWhenPushed;
}

- (void)setContentSizeForViewInPopover:(CGSize)newSize
{
    NS_UNIMPLEMENTED_LOG;
//    self.topViewController.contentSizeForViewInPopover = newSize;
}

- (CGSize)contentSizeForViewInPopover
{
    NS_UNIMPLEMENTED_LOG;
    return CGSizeZero;
//    return self.topViewController.contentSizeForViewInPopover;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated; // doesn't yet animate
{
    _navigationBarHidden = navigationBarHidden;
    
    CGRect visibleFrame = [self _navigationBarFrame];
    CGRect invisibleFrame = visibleFrame;
    invisibleFrame.origin.y -= visibleFrame.size.height;
    
    CGRect targetFrame = visibleFrame;
    if (navigationBarHidden) {
        targetFrame = invisibleFrame;
    }
    
    if (animated) {
        if (!navigationBarHidden) {
            _navigationBar.hidden = NO;
        }

        // this shouldn't just hide it, but should animate it out of view (if animated==YES) and then adjust the layout
        // so the main view fills the whole space, etc.
        [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
            _navigationBar.frame = targetFrame;
            
            // TODO: adjust main view
            _visibleViewController.view.frame = [self _controllerFrameForTransition:_UINavigationControllerVisibleControllerTransitionNone];
        } completion:^(BOOL finished) {
            _navigationBar.hidden = navigationBarHidden;
        }];
    } else {
        _navigationBar.frame = targetFrame;
        _navigationBar.hidden = navigationBarHidden;
        
        _visibleViewController.view.frame = [self _controllerFrameForTransition:_UINavigationControllerVisibleControllerTransitionNone];
    }
    
    
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

- (void)setToolbarItems:(NSArray *)toolbarItems
{
    [self setToolbarItems:toolbarItems animated:NO];
}

- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end

@implementation UIViewController (UINavigationControllerItem)

- (UINavigationItem *)navigationItem
{
    if (!_navigationItem) {
        _navigationItem = [[UINavigationItem alloc] initWithTitle:self.title];
    }
    return _navigationItem;
}

- (BOOL)hidesBottomBarWhenPushed
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
{
    NS_UNIMPLEMENTED_LOG;
}

- (id)_nearestParentViewControllerThatIsKindOf:(Class)c
{
    UIViewController *controller = [self parentViewController];
    
    while (controller && ![controller isKindOfClass:c]) {
        controller = [controller parentViewController];
    }
    
    return controller;
}

- (UINavigationController *)navigationController
{
    return [self _nearestParentViewControllerThatIsKindOf:[UINavigationController class]];
}

@end

@implementation UIViewController (UINavigationControllerContextualToolbarItems)

- (NSArray *)toolbarItems
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)setToolbarItems:(NSArray *)toolbarItems
{
    [self setToolbarItems:toolbarItems animated:NO];
}

- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}

@end
