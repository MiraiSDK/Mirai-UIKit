//
//  UIViewController.m
//  UIKit
//
//  Created by Chen Yonghui on 2/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIViewController.h"
#import "UIView+UIPrivate.h"

#import "UIScreen.h"
#import "UIWindow.h"
#import "UIWindow+UIPrivate.h"

@implementation UIViewController {
    NSMutableArray *_childViewControllers;
    
    BOOL _isBeingPresented;
    BOOL _isBeingDismissed;
    NSValue *_instanceValue;
}
@synthesize view = _view;
@synthesize presentingViewController = _presentingViewController;
@synthesize presentedViewController = _presentedViewController;

//we record every view controller instance, to send memory warning message
static NSMutableArray *_viewControllerInstances;

+ (void) initialize
{
    if (self == [UIViewController class]) {
        _viewControllerInstances = [NSMutableArray array];
    }
}

+ (void)_performMemoryWarning
{
    NSArray *vcs = [_viewControllerInstances copy];
    for (NSValue *value in vcs) {
        UIViewController *vc = [value nonretainedObjectValue];
        [vc didReceiveMemoryWarning];
    }
}

- (void)dealloc
{
    if (![NSThread isMainThread]) {
        NSLog(@"[ERROR] view controller doesn't dealloc on mainthread");
    }
    [_viewControllerInstances removeObject:_instanceValue];
}

- (id)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super init];
    if (self) {
//        _contentSizeForViewInPopover = CGSizeMake(320,1100);
//        _hidesBottomBarWhenPushed = NO;
        _navigationItem = nil;
        _automaticallyAdjustsScrollViewInsets = YES;
        _edgesForExtendedLayout = UIRectEdgeAll;
        _extendedLayoutIncludesOpaqueBars = NO;
        
        _instanceValue = [NSValue valueWithNonretainedObject:self];
        [_viewControllerInstances addObject:_instanceValue];
    }
    return self;
}

- (UIResponder *)nextResponder
{
    return _view.superview;
}

- (BOOL)isViewLoaded
{
    return (_view != nil);
}

- (UIView *)view
{
    if ([self isViewLoaded]) {
        return _view;
    } else {
        [self loadView];
        [self viewDidLoad];
        return _view;
    }
}

- (void)setView:(UIView *)view
{
    if (view != _view) {
        [_view _setViewController:nil];
        _view = view;
        [_view _setViewController:self];
    }
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void)viewDidLoad
{
}

- (void)viewDidUnload
{
}

- (void)didReceiveMemoryWarning
{
}

- (void)viewWillAppear:(BOOL)animated
{
    for (UIViewController *child in self.childViewControllers) {
        if (child.isViewLoaded) {
            [child viewWillAppear:animated];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
    for (UIViewController *child in self.childViewControllers) {
        if (child.isViewLoaded) {
            [child viewDidAppear:animated];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    for (UIViewController *child in self.childViewControllers) {
        [child viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    for (UIViewController *child in self.childViewControllers) {
        [child viewDidDisappear:animated];
    }
}

- (void)viewWillLayoutSubviews
{
}

- (void)viewDidLayoutSubviews
{
}

- (UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientation)UIDeviceOrientationPortrait;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NS_UNIMPLEMENTED_LOG;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NS_UNIMPLEMENTED_LOG;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NS_UNIMPLEMENTED_LOG;
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)_setParentViewController:(UIViewController *)parentController
{
    _parentViewController = parentController;
}

#pragma mark -

- (UIViewController *)presentedViewController
{
    UIViewController *result = _presentedViewController;
    if (!result) {
        for (UIViewController *child in [self childViewControllers]) {
            result = [child presentedViewController];
            if (result) {
                break;
            }
        }
    }
    
    return result;
}

- (UIViewController *)presentingViewController
{
    UIViewController *farestPresenting = _presentingViewController;
    
    UIViewController *parent = self.parentViewController;
    while (parent) {
        UIViewController *presenting = parent->_presentingViewController;
        if (presenting) {
            farestPresenting = presenting;
        }
        
        parent = parent.parentViewController;
    }
    
    UIViewController *result = farestPresenting;
    while (result.parentViewController) {
        result = result.parentViewController;
    }
    
    
    return result;
}

- (UIViewController *)_nearstPresentingViewController
{
    UIViewController *nearstPresenting = _presentingViewController;
    
    UIViewController *parent = self.parentViewController;
    while (!nearstPresenting) {
        UIViewController *presenting = parent->_presentingViewController;
        if (presenting) {
            nearstPresenting = presenting;
        }
    }
    
    return nearstPresenting;
}

- (BOOL)isBeingPresented
{
    return _isBeingPresented;
}

- (BOOL)isBeingDismissed
{
    return _isBeingDismissed;
}

- (BOOL)isMovingToParentViewController
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (BOOL)isMovingFromParentViewController
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

#define kViewControllerTransitionDuration 0.25

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)animated completion:(void (^)(void))completion
{
    _presentedViewController = viewControllerToPresent;
    viewControllerToPresent->_presentingViewController = self;
    
    _isBeingPresented = YES;
    
    UIWindow *window = self.view.window;
    UIView *selfView = self.view;
    while (selfView.superview && ![selfView.superview isKindOfClass:[UIWindow class]]) {
        selfView = selfView.superview;
    }
    
    UIView *newView = viewControllerToPresent.view;
    newView.autoresizingMask = selfView.autoresizingMask;

    CGRect frame = window.bounds;
    CGRect frameBeforeAnimation = frame;
    frameBeforeAnimation.origin.y += frame.size.height;
    
    newView.frame = frameBeforeAnimation;
    [window addSubview:newView];

    [viewControllerToPresent viewWillAppear:animated];
    [self viewWillDisappear:animated];
    
    [UIView animateWithDuration:animated ? kViewControllerTransitionDuration : 0 animations:^{
        newView.frame = frame;
    } completion:^(BOOL finished) {
        _isBeingPresented = NO;
        
        [selfView removeFromSuperview];
        [self resignFirstResponder];
        
        [self viewDidDisappear:animated];
        
        [viewControllerToPresent viewDidAppear:animated];

        if (completion) {
            completion();
        }
    }];
}

- (void)dismissViewControllerAnimated: (BOOL)animated completion: (void (^)(void))completion
{
    UIViewController *ed = _presentedViewController;
    UIViewController *ing = _presentingViewController;
    if (!_presentedViewController) {
        [self._nearstPresentingViewController dismissViewControllerAnimated:animated completion:completion];
        return;
    }
    
    _isBeingDismissed = YES;
    
    UIWindow *window = _presentedViewController.view.window;
    
    CGRect frame = _wantsFullScreenLayout? window.screen.bounds : window.screen.applicationFrame;

    
    UIView *viewToReadd = self.view;
    while (viewToReadd.superview && ![viewToReadd.superview isKindOfClass:[UIWindow class]]) {
        viewToReadd = viewToReadd.superview;
    }

    viewToReadd.frame = frame;
    [window insertSubview:viewToReadd belowSubview:_presentedViewController.view];
    
    [self viewWillAppear:animated];
    [_presentedViewController viewWillDisappear:animated];
    
    
    CGRect frameAfterAnimation = frame;
    frameAfterAnimation.origin.y += frame.size.height;

    [UIView animateWithDuration:animated ? kViewControllerTransitionDuration : 0 animations:^{
        _presentedViewController.view.frame = frameAfterAnimation;
    } completion:^(BOOL finished) {
        _isBeingDismissed = YES;
        
        [_presentedViewController.view removeFromSuperview];
        [_presentedViewController viewDidDisappear:animated];
        [self viewDidAppear:animated];
        
        if (_presentedViewController) {
            _presentedViewController->_presentingViewController = nil;
            _presentedViewController = nil;            
        }
        
        if (completion) {
            completion();
        }
    }];

}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated{
    if (!_modalViewController && _modalViewController != self) {
        _modalViewController = modalViewController;
        [_modalViewController _setParentViewController:self];
        
        UIWindow *window = self.view.window;
        UIView *selfView = self.view;
        UIView *newView = _modalViewController.view;
        
        newView.autoresizingMask = selfView.autoresizingMask;
        newView.frame = _wantsFullScreenLayout? window.screen.bounds : window.screen.applicationFrame;
        
        [window addSubview:newView];
        [_modalViewController viewWillAppear:animated];
        
        [self viewWillDisappear:animated];
        selfView.hidden = YES;		// I think the real one may actually remove it, which would mean needing to remember the superview, I guess? Not sure...
        [self viewDidDisappear:animated];
        
        
        [_modalViewController viewDidAppear:animated];
    }

}// NS_DEPRECATED_IOS(2_0, 6_0);

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}// NS_DEPRECATED_IOS(2_0, 6_0);

- (BOOL)disablesAutomaticKeyboardDismissal
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    NS_UNIMPLEMENTED_LOG;
    return UIStatusBarStyleDefault;
}// NS_AVAILABLE_IOS(7_0);
- (BOOL)prefersStatusBarHidden{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}// NS_AVAILABLE_IOS(7_0);

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    NS_UNIMPLEMENTED_LOG;
    return UIStatusBarAnimationNone;
}// NS_AVAILABLE_IOS(7_0);

- (void)setNeedsStatusBarAppearanceUpdate{
    NS_UNIMPLEMENTED_LOG;
}// NS_AVAILABLE_IOS(7_0);


@end

@implementation UIViewController (UIViewControllerEditing)
@dynamic editing;

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}

@end

@implementation UIViewController (UISearchDisplayControllerSupport)
@dynamic searchDisplayController;

@end

@implementation UIViewController (UIContainerViewControllerProtectedMethods)

- (NSArray *)childViewControllers
{
    return [self m_ChildViewControllers];
}

- (void)setChildViewControllers:(NSArray *)childViewControllers
{
    _childViewControllers = [childViewControllers mutableCopy];
}

- (NSMutableArray *)m_ChildViewControllers
{
    if (!_childViewControllers) {
        _childViewControllers = [NSMutableArray array];
    }
    
    return _childViewControllers;
}

- (void)addChildViewController:(UIViewController *)childController
{
    [[self m_ChildViewControllers] addObject:childController];
    [childController _setParentViewController:self];
    [childController willMoveToParentViewController:self];
}

- (void)removeFromParentViewController
{
    [[self.parentViewController m_ChildViewControllers] removeObject:self];
    [self _setParentViewController:nil];
    [self didMoveToParentViewController:nil];
}

- (void)beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)endAppearanceTransition
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion
{
    //FIXME: options?
    UIView *superView = fromViewController.view.superview;
    
    // FIXME: workaround here
    //  should use UIView transition to trigger view appear/disappear message
    [UIView animateWithDuration:duration animations:^{
        [fromViewController viewWillDisappear:YES];
        [toViewController viewWillAppear:YES];
        
        [fromViewController.view removeFromSuperview];
        [superView addSubview:toViewController.view];
        toViewController.view.frame = fromViewController.view.frame;
    } completion:^(BOOL finished) {
        [toViewController viewDidAppear:YES];
        [fromViewController viewDidDisappear:YES];
        if (completion) {
            completion(finished);
        }
    }];
    NS_UNIMPLEMENTED_LOG;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}
@end

@implementation UIViewController (UIContainerViewControllerCallbacks)

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent) {
        if ([parent isViewLoaded]) {
        }
    } else {
        [self viewWillDisappear:NO];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (parent) {
        if ([parent isViewLoaded]) {
            [self viewWillAppear:NO];
            [self viewDidAppear:NO];
        }
    } else {
        [self viewDidDisappear:NO];
    }
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}// NS_DEPRECATED_IOS(5_0,6_0);

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}
- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

@end

@implementation UIViewController (UIConstraintBasedLayoutCoreMethods)

- (void)updateViewConstraints
{
    NS_UNIMPLEMENTED_LOG;
}

@end

@implementation UIViewController (CustomTransitioning)
@dynamic transitioningDelegate;

@end

@implementation UIViewController (UIViewControllerRotation)
+ (void)attemptRotationToDeviceOrientation
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown |UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIView *)rotatingHeaderView
{
    return nil;
}

- (UIView *)rotatingFooterView
{
    return nil;
}

- (UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}


@end