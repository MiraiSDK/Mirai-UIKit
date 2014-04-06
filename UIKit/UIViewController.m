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

@implementation UIViewController {
    NSMutableArray *_childViewControllers;
}
@synthesize view = _view;

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
        [child viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
    for (UIViewController *child in self.childViewControllers) {
        [child viewDidAppear:animated];
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


- (BOOL)isBeingPresented
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (BOOL)isBeingDismissed
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
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

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion
{
    NS_UNIMPLEMENTED_LOG;
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated{
    NS_UNIMPLEMENTED_LOG;
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
    childController->_parentViewController = self;
    [childController willMoveToParentViewController:self];
}

- (void)removeFromParentViewController
{
    [[self.parentViewController m_ChildViewControllers] removeObject:self];
    self->_parentViewController = nil;
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
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown |UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
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