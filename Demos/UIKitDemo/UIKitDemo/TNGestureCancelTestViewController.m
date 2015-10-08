//
//  TNGestureCancelTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/10/8.
//  Copyright © 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNGestureCancelTestViewController.h"
#import "TNCancelGeneratorGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface _TNGestureCancelTestRecognizer : UITapGestureRecognizer @end

@implementation TNGestureCancelTestViewController
{
    UIView *_gestureAreaView;
}
+ (NSString *)testName
{
    return @"test gesture cancel.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"reset" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(30, 150, 100, 50)];
    [self.view addSubview:button];
    
    _gestureAreaView = [[UIView alloc] initWithFrame:CGRectMake(30, 250, 300, 400)];
    _gestureAreaView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_gestureAreaView];
    
    [button addTarget:self action:@selector(_onReset:) forControlEvents:UIControlEventTouchUpInside];
    [self _reset];
}

- (void)_onReset:(id)sender
{
    [self _reset];
}

- (void)_reset
{
    if ([_gestureAreaView gestureRecognizers].count > 0) {
        UIGestureRecognizer *recognizer = [[_gestureAreaView gestureRecognizers] firstObject];
        [_gestureAreaView removeGestureRecognizer:recognizer];
    }
    
    TNCancelGeneratorGestureRecognizer *recognizer = [[TNCancelGeneratorGestureRecognizer alloc] init];
    recognizer.proxyGestureRecognizer = [[_TNGestureCancelTestRecognizer alloc] init];
    [_gestureAreaView addGestureRecognizer:recognizer];
}

@end

@implementation _TNGestureCancelTestRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@">> %s", __FUNCTION__);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    NSLog(@">> %s", __FUNCTION__);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSLog(@">> %s", __FUNCTION__);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    NSLog(@">> %s", __FUNCTION__);
}

@end