//
//  TNTapGestureRecognizerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/8/31.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTapGestureRecognizerTestViewController.h"

@implementation TNTapGestureRecognizerTestViewController


+ (NSString *)testName
{
    return @"UITapGestureRecognizer recognize test.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapRecognizer addTarget:self action:@selector(_onRecognize:)];
    
    [self.view addGestureRecognizer:tapRecognizer];
    
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    
}

- (void)_onRecognize:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"=> %s", __FUNCTION__);
}

@end
