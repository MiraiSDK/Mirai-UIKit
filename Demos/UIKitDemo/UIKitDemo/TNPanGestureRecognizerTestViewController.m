//
//  TNPanGestureRecognizerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/9/1.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNPanGestureRecognizerTestViewController.h"

@implementation TNPanGestureRecognizerTestViewController

+ (NSString *)testName
{
    return @"UIPanGestureRecognizer recognize test.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    [panGestureRecognizer addTarget:self action:@selector(_onRecognize:)];
    
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    panGestureRecognizer.maximumNumberOfTouches = 3;
    panGestureRecognizer.minimumNumberOfTouches = 2;
}

- (void)_onRecognize:(UIPanGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"=> translation %@", NSStringFromCGPoint([tapGestureRecognizer translationInView:self.view]));
}

@end
