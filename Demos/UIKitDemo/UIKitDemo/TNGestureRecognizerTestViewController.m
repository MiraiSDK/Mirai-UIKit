//
//  TNGestureRecognizerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/8/19.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNGestureRecognizerTestViewController.h"
#import "TNTouchShowMessage.h"
#import "TNTouchConfirmSuperview.h"
#import "TNGestureEffectTouch.h"
#import "TNTapGestureRecognizerTestViewController.h"
#import "TNPanGestureRecognizerTestViewController.h"
#import "TNRecognizerToFailTestViewController.h"

@implementation TNGestureRecognizerTestViewController

+ (NSString *)testName
{
    return @"UIGestureRecognizer Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSArray *)subTests
{
    return @[
             TNRecognizerToFailTestViewController.class,
             TNTouchShowMessage.class,
             TNTouchConfirmSuperview.class,
             TNGestureEffectTouch.class,
             TNTapGestureRecognizerTestViewController.class,
             TNPanGestureRecognizerTestViewController.class,
             ];
}

@end
