//
//  TNTabBarItemTestController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/26.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTabBarItemTestController.h"
#import "TNComponentCreator.h"

@interface TNTabBarItemTestController ()
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UITabBar *bar;
@end

@implementation TNTabBarItemTestController

+ (NSString *)testName
{
    return @"UITabBarItem Test";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _makeTabBarItems];
    [self _makeTabBar];
    [self _makeChangeValueSliders];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)_makeTabBarItems
{
    UIImage *catImage = [UIImage imageNamed:@"tabicon0.png"];
    
    self.items = @[
                   [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads
                                                              tag:0],
                   [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites
                                                              tag:1],
                   [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory
                                                              tag:2],
                   [[UITabBarItem alloc] initWithTitle:@"cat" image:catImage tag:3],
    ];
}

- (void)_makeTabBar
{
    self.bar =  [[UITabBar alloc] initWithFrame:CGRectMake(5, 130, 250, 50)];
    [self.view addSubview:self.bar];
    [self.bar setItems:self.items];
}

- (void)_makeChangeValueSliders
{
    [TNComponentCreator makeChangeValueSliderWithTitle:@"Width" at:290 withControl:self withMaxValue:350 whenValueChanged:^(float value) {
        CGRect oldFrame = self.bar.frame;
        self.bar.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y,
                                    value, oldFrame.size.height);
    }];
    [TNComponentCreator makeChangeValueSliderWithTitle:@"Height" at:340 withControl:self withMaxValue:250 whenValueChanged:^(float value) {
        CGRect oldFrame = self.bar.frame;
        self.bar.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y,
                                    oldFrame.size.width, value);
    }];
    [TNComponentCreator makeChangeValueSliderWithTitle:@"position hoprizontal" at:390
                                           withControl:self withMaxValue:50 whenValueChanged:^(float value) {
        [self _doForEachTabBarItems:^(UITabBarItem *item, NSUInteger index) {
            item.titlePositionAdjustment = UIOffsetMake(value, item.titlePositionAdjustment.vertical);
        }];
    }];
    [TNComponentCreator makeChangeValueSliderWithTitle:@"position vertical" at:440
                                           withControl:self withMaxValue:50 whenValueChanged:^(float value) {
        [self _doForEachTabBarItems:^(UITabBarItem *item, NSUInteger index) {
            item.titlePositionAdjustment = UIOffsetMake(item.titlePositionAdjustment.horizontal, value);
        }];
    }];
}

- (void)_doForEachTabBarItems:(void (^)(UITabBarItem *item, NSUInteger index))callback
{
    for (NSUInteger index = 0; index < [self.items count]; index++) {
        UITabBarItem *item = (UITabBarItem *)[self.items objectAtIndex:index];
        callback(item, index);
    }
}

@end
