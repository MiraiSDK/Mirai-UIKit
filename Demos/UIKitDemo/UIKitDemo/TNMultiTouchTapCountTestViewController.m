//
//  TNMultiTouchTapCountTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/10/3.
//  Copyright © 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNMultiTouchTapCountTestViewController.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface _TNMultiTouchTapCountTestGestureRecognizer : UIGestureRecognizer @end

@implementation TNMultiTouchTapCountTestViewController

+ (NSString *)testName
{
    return @"UITouch.tapCount Test";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIGestureRecognizer *gestureRecognizer = [[_TNMultiTouchTapCountTestGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:gestureRecognizer];
}

@end

@implementation _TNMultiTouchTapCountTestGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _showMethod:@"Began" andTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _showMethod:@"Moved" andTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _showMethod:@"Ended" andTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _showMethod:@"Cancelled" andTouches:touches];
}

- (void)_showMethod:(NSString *)methodName andTouches:(NSSet *)touches
{
    NSMutableArray *touchesInfo = [[NSMutableArray alloc] init];
    for (UITouch *touch in touches) {
        NSString *info = [NSString stringWithFormat:@"%@[%li]-%li",
                          NSStringFromCGPoint([touch locationInView:nil]), touch.hash, touch.tapCount];
        [touchesInfo addObject:info];
    }
    NSLog(@"recive [%@] : %@", methodName, [touchesInfo componentsJoinedByString:@", "]);
}

@end
