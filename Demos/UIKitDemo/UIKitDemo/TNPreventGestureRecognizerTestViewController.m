//
//  TNPreventGestureRecognizerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/9/21.
//  Copyright © 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNPreventGestureRecognizerTestViewController.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface TNPreventGestureRecognizerTestViewController () <UIGestureRecognizerDelegate> @end
@interface _TNPreventTapGestureRecognizer : UITapGestureRecognizer @end

@implementation TNPreventGestureRecognizerTestViewController
{
    UITapGestureRecognizer *_recognizer;
}

+ (NSString *)testName
{
    return @"test prevent gesture recognizers behavior.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _recognizer = [[_TNPreventTapGestureRecognizer alloc] init];
    [_recognizer addTarget:self action:@selector(_onRecognizer:)];
    [_recognizer setDelegate:self];
    [self.view addGestureRecognizer:_recognizer];
    
    _recognizer.numberOfTapsRequired = 2;
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    return NO;
//}

- (void)_onRecognizer:(UIGestureRecognizer *)recognizer
{
    NSLog(@"prevent tap gesture recognizer recognized!!!");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"attached view recived BEGAN event - state(%zi)", _recognizer.state);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"attached view recived MOVED event - state(%zi)", _recognizer.state);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"attached view recived ENDED event - state(%zi)", _recognizer.state);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"attached view recived CANCELLED event - state(%zi)", _recognizer.state);
}

@end

@implementation _TNPreventTapGestureRecognizer

- (void)reset
{
    [super reset];
    NSLog(@"tap gesture recognizer reset!!!");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"tap gesture recognizer recived BEGAN event - state(%zi)", self.state);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    NSLog(@"tap gesture recognizer recived MOVED event - state(%zi)", self.state);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"tap gesture recognizer recived ENDED event - state(%zi)", self.state);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"tap gesture recognizer recived CANCELLED event - state(%zi)", self.state);
}

@end