//
//  TNDisplayModeTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/14.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNDisplayModeTestViewController.h"
#import "TNBlockButton.h"

@interface TNDisplayModeTestViewController ()
@property (nonatomic) NSUInteger nextButtonIndex;
@property (nonatomic, strong) id displayModeTarget;
@property (nonatomic) SEL displayModeAction;
@end

@implementation TNDisplayModeTestViewController

+ (NSString *)testName
{
    return @"test display mode.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIViewController *primaryViewController = [self _createViewControllerWithBackgroundColor:[UIColor redColor]];
    UIViewController *secondaryViewController = [self _createViewControllerWithBackgroundColor:[UIColor blueColor]];
    
    [self _packNavigationForPrimaryViewController:primaryViewController
                       andSecondaryViewController:secondaryViewController];
    [self _makeSubivewsForPrimaryViewController:primaryViewController];
    [self _makeDisplayModeButtonItemForSecondaryViewController:secondaryViewController];
    [self _printCurrentDisplayMode];
}

- (UIViewController *)_createViewControllerWithBackgroundColor:(UIColor *)backgroundColor
{
    UIViewController *viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    viewController.view.backgroundColor = backgroundColor;
    return viewController;
}

- (void)_packNavigationForPrimaryViewController:(UIViewController *)primaryViewController
                     andSecondaryViewController:(UIViewController *)secondaryViewController
{
    UINavigationController *primaryNavigation = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:[UIToolbar class]];
    UINavigationController *secondaryNavigation = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:[UIToolbar class]];
    
    self.viewControllers = @[primaryNavigation, secondaryNavigation];
    
    [primaryNavigation pushViewController:primaryViewController animated:NO];
    [secondaryNavigation pushViewController:secondaryViewController animated:NO];
}

- (void)_makeSubivewsForPrimaryViewController:(UIViewController *)primaryViewController
{
    [self _makeButtonTitle:@"ModeAutomatic"
                      mode:UISplitViewControllerDisplayModeAutomatic
                 superView:primaryViewController];
    
    [self _makeButtonTitle:@"PrimaryHidden"
                      mode:UISplitViewControllerDisplayModePrimaryHidden
                 superView:primaryViewController];
    
    [self _makeButtonTitle:@"AllVisible"
                      mode:UISplitViewControllerDisplayModeAllVisible
                 superView:primaryViewController];
    
    [self _makeButtonTitle:@"PrimaryOverlay"
                      mode:UISplitViewControllerDisplayModePrimaryOverlay
                 superView:primaryViewController];
}

- (void)_makeDisplayModeButtonItemForSecondaryViewController:(UIViewController *)secondaryViewController
{
    secondaryViewController.navigationItem.leftBarButtonItem = self.displayModeButtonItem;
    [self _replaceTarget:self action:@selector(_onTappedSelfDisplayModeButtonItem:)
         ofBarButtonItem:self.displayModeButtonItem];
}

- (void)_replaceTarget:(id)target action:(SEL)action ofBarButtonItem:(UIBarButtonItem *)buttonItem
{
    _displayModeTarget = buttonItem.target;
    _displayModeAction = buttonItem.action;
    buttonItem.target = target;
    buttonItem.action = action;
}

- (void)_makeButtonTitle:(NSString *)title mode:(UISplitViewControllerDisplayMode)mode superView:(UIViewController *)superView
{
    __weak typeof(self) weakSelf = self;
    UIButton *button = [TNBlockButton blockButtonWhenTapped:^{
        weakSelf.preferredDisplayMode = mode;
        [weakSelf _printCurrentDisplayMode];
    }];
    [button setTitle:title forState:UIControlStateNormal];
    
    static const CGFloat StartLocation = 100;
    static const CGFloat Interval = 25;
    static const CGFloat ButtonWidth = 300;
    static const CGFloat ButtonHeight = 70;
    
    button.frame = CGRectMake(5, StartLocation + _nextButtonIndex*(Interval + ButtonHeight),
                              ButtonWidth, ButtonHeight);
    _nextButtonIndex++;
    
    [superView.view addSubview:button];
}

- (void)_onTappedSelfDisplayModeButtonItem:(id)sender
{
    [_displayModeTarget performSelector:_displayModeAction withObject:sender];
    [self _printCurrentDisplayMode];
}

- (void)_printCurrentDisplayMode
{
    NSLog(@"self.displayMode == %@", [self _nameWithDisplayMode:self.displayMode]);
    NSLog(@"preferredDisplayMode == %@", [self _nameWithDisplayMode:self.preferredDisplayMode]);
}

- (NSString *)_nameWithDisplayMode:(UISplitViewControllerDisplayMode)mode
{
    switch (mode) {
        case UISplitViewControllerDisplayModeAutomatic:
            return @"Automatic";
            
        case UISplitViewControllerDisplayModePrimaryHidden:
            return @"ModePrimaryHidden";
            
        case UISplitViewControllerDisplayModeAllVisible:
            return @"AllVisible";
            
        case UISplitViewControllerDisplayModePrimaryOverlay:
            return @"PrimaryOverlay";
            
        default:
            return nil;
    }
}

@end
