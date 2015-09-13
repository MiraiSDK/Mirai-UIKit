//
//  TNMultiGestureRecognizerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/9/7.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "TNMultiGestureRecognizerTestViewController.h"

@interface _TNNeverMakeConclusionGestureRecognizer : UIGestureRecognizer @end
@interface _TNShowMessagePanGestureRecognizer : UIPanGestureRecognizer @end

@implementation TNMultiGestureRecognizerTestViewController

+ (NSString *)testName
{
    return @"test behavior multi gesture recognizer callback";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIGestureRecognizer *gestureRecognizer0 = [[_TNShowMessagePanGestureRecognizer alloc] init];
    UIGestureRecognizer *gestureRecognizer1 = [[_TNShowMessagePanGestureRecognizer alloc] init];
    UIGestureRecognizer *neverMakeConclusionRecognizer =
                [[_TNNeverMakeConclusionGestureRecognizer alloc] init];
    
    [gestureRecognizer0 addTarget:self action:@selector(_onGestureRecognized0:)];
    [gestureRecognizer1 addTarget:self  action:@selector(_onGestureRecognized1:)];
    
    [self.view addGestureRecognizer:gestureRecognizer0];
    [self.view addGestureRecognizer:gestureRecognizer1];
    [self.view addGestureRecognizer:neverMakeConclusionRecognizer];
}

- (void)_onGestureRecognized0:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gesture recognized 0 state %zi", gestureRecognizer.state);
}

- (void)_onGestureRecognized1:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gesture recognized 1 state %zi", gestureRecognizer.state);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"attched view recive touchesBegan method.");
}

@end

@implementation _TNShowMessagePanGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"<< %s", __FUNCTION__);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    NSLog(@"<< %s", __FUNCTION__);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"<< %s", __FUNCTION__);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"<< %s", __FUNCTION__);
}

@end

@implementation _TNNeverMakeConclusionGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"never make conclusion gesture recognizer's state is %zi", self.state);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {}

@end