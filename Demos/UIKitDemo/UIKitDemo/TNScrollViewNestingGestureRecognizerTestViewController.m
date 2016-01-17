//
//  TNScrollViewNestingGestureRecognizerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 16/1/14.
//  Copyright © 2016年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNScrollViewNestingGestureRecognizerTestViewController.h"

@implementation TNScrollViewNestingGestureRecognizerTestViewController

+ (NSString *)testName
{
    return @"Nesting Gesture Recognizer";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 70, 200, 200)];
    scrollView.backgroundColor = [UIColor redColor];
    scrollView.contentSize = CGSizeMake(600, 600);
    [self.view addSubview:scrollView];
    
    UIView *inner = [[UIView alloc] initWithFrame:CGRectMake(50, 40, 150, 150)];
    inner.backgroundColor = [UIColor blueColor];
    [scrollView addSubview:inner];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressAction:)];
    [inner addGestureRecognizer:longPressGestureRecognizer];
}

- (void)onLongPressAction:(id)sender
{
    NSLog(@"-> %s", __FUNCTION__);
}

@end
