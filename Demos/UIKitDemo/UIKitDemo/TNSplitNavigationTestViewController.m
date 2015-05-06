//
//  TNSplitNavigationTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/10.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNSplitNavigationTestViewController.h"
#import "TNComponentCreator.h"
#import "TNPrintSplitViewControllerDelegateMessage.h"

@interface TNSplitNavigationTestViewController ()
@property (nonatomic, strong) UINavigationController *primaryNavigationController;
@property (nonatomic, strong) UINavigationController *secondaryNavigationController;
@property (nonatomic, strong) UISlider *preferredWidthSlider;
@property (nonatomic, strong) UILabel *primaryColumnWidthLabel;
@property (nonatomic, strong) TNPrintSplitViewControllerDelegateMessage *bindedDelegate;
@end

@implementation TNSplitNavigationTestViewController

+ (NSString *)testName
{
    return @"test navigation.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _makeTwoSubViewControllers];
    [self _bindDelegate];
}

- (void)_makeTwoSubViewControllers
{
    UIViewController *primaryViewController = [self _createPrimaryViewController];

    UIViewController *secondaryViewController = [self _createViewControllerWithBackgroundColor:[UIColor blackColor]];
    _primaryNavigationController = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:[UIToolbar class]];
    _secondaryNavigationController = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:[UIToolbar class]];
    self.viewControllers = @[_primaryNavigationController, _secondaryNavigationController];
    [_primaryNavigationController pushViewController:primaryViewController animated:NO];
    [_secondaryNavigationController pushViewController:secondaryViewController animated:NO];
}

- (void)_bindDelegate
{
    _bindedDelegate = [[TNPrintSplitViewControllerDelegateMessage alloc] init];
    self.delegate = _bindedDelegate;
}

- (UIViewController *)_createPrimaryViewController
{
    UIViewController *primary = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    [self _makePushButtonsForPrimaryViewController:primary];
    [self _makeComponentsAboutCloumnWidthForPrimaryViewController:primary];
    primary.view.backgroundColor = [UIColor greenColor];
    return primary;
}

- (void)_makePushButtonsForPrimaryViewController:(UIViewController *)primaryViewController
{
    UIButton *pushToPrimaryButton = [TNComponentCreator createButtonWithTitle:@"push to primary"
                                                                    withFrame:CGRectMake(5, 100, 110, 30)];
    UIButton *pushToSecondaryButton = [TNComponentCreator createButtonWithTitle:@"push to secondary"
                                                                      withFrame:CGRectMake(5, 140, 110, 30)];
    [primaryViewController.view addSubview:pushToPrimaryButton];
    [primaryViewController.view addSubview:pushToSecondaryButton];
    
    [pushToPrimaryButton addTarget:self action:@selector(_onTappedPushToPrimaryButton:) forControlEvents:UIControlEventTouchUpInside];
    [pushToSecondaryButton addTarget:self action:@selector(_onTappedPushToSecondaryButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_makeComponentsAboutCloumnWidthForPrimaryViewController:(UIViewController *)primaryViewController
{
    _preferredWidthSlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 200, 200, 50)];
    _primaryColumnWidthLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 236, 200, 50)];
    [self _refreshPrimaryColumnWidthLabel];
    [primaryViewController.view addSubview:_preferredWidthSlider];
    [primaryViewController.view addSubview:_primaryColumnWidthLabel];
    
    [_preferredWidthSlider addTarget:self action:@selector(_onPreferredWidthSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (UIViewController *)_createViewControllerWithBackgroundColor:(UIColor *)color
{
    UIViewController *viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    viewController.view.backgroundColor = color;
    return viewController;
}

- (void)_onTappedPushToPrimaryButton:(id)sender
{
    UIViewController *viewController = [self _createViewControllerWithBackgroundColor:[self _extractRandomColor]];
    [_primaryNavigationController pushViewController:viewController animated:YES];
}

- (void)_onTappedPushToSecondaryButton:(id)sender
{
    UIViewController *viewController = [self _createViewControllerWithBackgroundColor:[self _extractRandomColor]];
    [_secondaryNavigationController pushViewController:viewController animated:YES];
}

- (void)_onPreferredWidthSliderValueChanged:(id)sender
{
    self.preferredPrimaryColumnWidthFraction = _preferredWidthSlider.value;
    [self _refreshPrimaryColumnWidthLabel];
}

- (void)_refreshPrimaryColumnWidthLabel
{
    _primaryColumnWidthLabel.text = [NSString stringWithFormat:@"width = %f", self.primaryColumnWidth];
    NSLog(@"self.primaryColumnWidth = %f", self.primaryColumnWidth);
    NSLog(@"self.preferredPrimaryColumnWidthFraction = %f", self.preferredPrimaryColumnWidthFraction);
}

- (UIColor *)_extractRandomColor
{
    static NSArray *colorList = nil;
    if (colorList == nil) {
        colorList = @[
                      [UIColor redColor],
                      [UIColor orangeColor],
                      [UIColor yellowColor],
                      [UIColor greenColor],
                      [UIColor blueColor],
                      [UIColor darkGrayColor],
                      [UIColor purpleColor],
                      ];
    }
    return [colorList objectAtIndex:arc4random_uniform((u_int32_t)colorList.count)];
}

@end
