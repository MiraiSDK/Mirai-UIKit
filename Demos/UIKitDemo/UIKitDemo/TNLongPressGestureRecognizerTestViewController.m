//
//  TNLongPressGestureRecognizerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/9/4.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNLongPressGestureRecognizerTestViewController.h"

@implementation TNLongPressGestureRecognizerTestViewController

+ (NSString *)testName
{
    return @"UILongPressGestureRecognizer recognize test.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [longPressRecognizer addTarget:self action:@selector(_onRecognize:)];
    
    [self.view addGestureRecognizer:longPressRecognizer];
    
    longPressRecognizer.allowableMovement = YES;
    longPressRecognizer.numberOfTapsRequired = 1;
    longPressRecognizer.numberOfTouchesRequired = 2;
    
}

- (void)_onRecognize:(UILongPressGestureRecognizer *)longPressRecognizer
{
    NSLog(@"=> %s state %i", __FUNCTION__, longPressRecognizer.state);
}

@end
