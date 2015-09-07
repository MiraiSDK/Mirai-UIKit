//
//  TNRecognizerToFailTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/9/7.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "TNRecognizerToFailTestViewController.h"

@interface _TNShowMessageGestureRecognizer : UITapGestureRecognizer
@property (nonatomic, strong) NSString *mark;
@end

@implementation TNRecognizerToFailTestViewController

+ (NSString *)testName
{
    return @"test method requireGestureRecognizerToFail:";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _TNShowMessageGestureRecognizer *originalRecognizer = [[_TNShowMessageGestureRecognizer alloc] init];
    _TNShowMessageGestureRecognizer *failToRecognizer = [[_TNShowMessageGestureRecognizer alloc] init];
    _TNShowMessageGestureRecognizer *failToRecognizer2 = [[_TNShowMessageGestureRecognizer alloc] init];
    
    originalRecognizer.mark = @"original";
    failToRecognizer.mark = @"fail";
    failToRecognizer2.mark = @"fail2";
    
    [originalRecognizer addTarget:self action:@selector(_onOriginalGestureRecognize:)];
    [failToRecognizer addTarget:self action:@selector(_onFailToGestureRecognizer:)];
    [failToRecognizer2 addTarget:self action:@selector(_onFailToGestureRecognizer:)];
    
    [failToRecognizer requireGestureRecognizerToFail:originalRecognizer];
    [failToRecognizer2 requireGestureRecognizerToFail:originalRecognizer];
    
    [self.view addGestureRecognizer:originalRecognizer];
    [self.view addGestureRecognizer:failToRecognizer];
    [self.view addGestureRecognizer:failToRecognizer2];
    
    originalRecognizer.numberOfTapsRequired = 2;
    failToRecognizer.numberOfTapsRequired = 1;
    failToRecognizer2.numberOfTapsRequired = 1;
}

- (void)_onOriginalGestureRecognize:(_TNShowMessageGestureRecognizer *)gestureRecognizer
{
    NSLog(@"TEST-METHOD Original state(%zi)", gestureRecognizer.state);
}

- (void)_onFailToGestureRecognizer:(_TNShowMessageGestureRecognizer *)gestureRecognizer
{
    NSLog(@"TEST-METHOD Fail state(%zi) for %@", gestureRecognizer.state, gestureRecognizer.mark);
}

@end

@implementation _TNShowMessageGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"recive %@ - %s", self.mark, __FUNCTION__);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    NSLog(@"recive %@ - %s", self.mark, __FUNCTION__);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"recive %@ - %s", self.mark, __FUNCTION__);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"recive %@ - %s", self.mark, __FUNCTION__);
}

@end