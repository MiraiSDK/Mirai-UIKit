//
//  TNChangeTabTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/22.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNChangeTabTestViewController.h"
#import "TNComponentCreator.h"
#import "TNTestCaseHelperButton.h"

@interface TNChangeTabTestViewController ()

@end

@implementation TNChangeTabTestViewController

+ (NSString *)testName
{
    return @"test change tab.";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _printViewControllerPropertesDefaultValues];
    [self _makeControllers];
    [self _makeTabs];
    [self _makeTestCaseButton];
}

- (void)_printViewControllerPropertesDefaultValues
{
    NSLog(@"selectedIndex : %li", self.selectedIndex);
}

- (void)_makeControllers
{
    self.viewControllers = @[
        [self _createViewControllerWithDescription:@"Controller(1)"],
        [self _createViewControllerWithDescription:@"Controller(2)"],
        [self _createOperateController],
        [self _createViewControllerWithDescription:@"Other"],
    ];
}

- (void)_makeTabs
{
    [self _setTabBarItem:[self _getTabBarItemAt:1] withImageName:@"loveheart.png"];
    [self _setTabBarItem:[self _getTabBarItemAt:0] withImageName:@"loveheart.png"];
    [self _setTabBarItem:[self _getTabBarItemAt:2] withImageName:@"tabicon0.png"];
}

- (void)_makeTestCaseButton
{
    TNTestCaseHelperButton *helperButton = [[TNTestCaseHelperButton alloc] initWithPosition:CGPointMake(5, 300)];
    [helperButton setInvokeTestCaseBlock:^(TNTestCaseHelperButton *helper) {
        [self _runTestCaseCode:helper];
    }];
    [self.view addSubview:helperButton];
}

- (void)_setTabBarItem:(UITabBarItem *)item withImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    item.image = image;
    item.selectedImage = image;
}

- (UIViewController *)_createViewControllerWithDescription:(NSString *)description
{
    UIViewController *controller = [[UIViewController alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 110, 300, 50)];
    label.text = description;
    label.textColor = [UIColor blueColor];
    
    controller.title = description;
    [controller.view addSubview:label];
    controller.view.backgroundColor = [UIColor whiteColor];
    return controller;
}

-(UIViewController *)_createOperateController
{
    UIViewController *controller = [self _createViewControllerWithDescription:@"test"];
    [self _makeImageZoomChangeButtonsForController:controller];
    return controller;
}

- (void)_makeImageZoomChangeButtonsForController:(UIViewController *)controller
{
    UIButton *imageZoomUp = [TNComponentCreator createButtonWithTitle:@"ING++"
                                                            withFrame:CGRectMake(5, 210, 50, 25)];
    UIButton *imageZoomOut = [TNComponentCreator createButtonWithTitle:@"IMG--"
                                                             withFrame:CGRectMake(120, 210, 50, 25)];
    [imageZoomUp addTarget:self action:@selector(_onClickImageZoomUp:)
          forControlEvents:UIControlEventTouchUpInside];
    [imageZoomOut addTarget:self action:@selector(_onClickImageZoomOut:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [controller.view addSubview:imageZoomUp];
    [controller.view addSubview:imageZoomOut];
}

- (void)_onClickImageZoomUp:(id)sender
{
    [self _resizeItemImageWithScale:1.25];
}

- (void)_onClickImageZoomOut:(id)sender
{
    [self _resizeItemImageWithScale:0.8];
}

- (void)_resizeItemImageWithScale:(float)scale
{
    [self _doForEachTabBarItems:^(UITabBarItem *item, NSUInteger index) {
        item.image = [self _createResizedImageWithSourceImage:item.image withScale:scale];
        item.selectedImage = [self _createResizedImageWithSourceImage:item.selectedImage
                                                            withScale:scale];
    }];
}

- (UIImage *)_createResizedImageWithSourceImage:(UIImage *)sourceImage withScale:(float)scale
{
    UIImage *targetImage = nil;
    if (sourceImage) {
        CGSize size = sourceImage.size;
        size = CGSizeMake(size.width*scale, size.height*scale);
        targetImage = [TNComponentCreator imageWithImage:sourceImage
                                            scaledToSize:size];
    }
    return targetImage;
}

- (void)_doForEachTabBarItems:(void (^)(UITabBarItem *item, NSUInteger index))callback
{
    for (NSUInteger index = 0; index < [self.tabBar.items count]; index++) {
        callback([self _getTabBarItemAt:index], index);
    }
}

- (UITabBarItem *)_getTabBarItemAt:(NSUInteger)index
{
    return (UITabBarItem *)[self.tabBar.items objectAtIndex:index];
}

- (void)_runTestCaseCode:(TNTestCaseHelperButton *)helper
{
    [self _testIsSelectedImageEqualsImageWhenNotAssignSelectedImage:helper];
    [self _testDefaultValueOfTabBarItemDelegateIsSuperViewController:helper];
}

- (void)_testIsSelectedImageEqualsImageWhenNotAssignSelectedImage:(TNTestCaseHelperButton *)helper
{
    UIImage *image = [[UIImage imageNamed:@"loveheart.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"haha" image:image tag:7];
    
    [helper assert:(item.selectedImage == item.image) forTest:@"initWithTitle:image:tag: function setting images."];
}

- (void)_testDefaultValueOfTabBarItemDelegateIsSuperViewController:(TNTestCaseHelperButton *)helper
{
    [helper assert:(self.tabBar.delegate == self) forTest:@"default delegate'value is super viewController."];
}

@end
