//
//  TNTouchShowMessage.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/8/19.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "TNTouchShowMessage.h"

#define kRedViewSpecialTag 888

static void ShowMessageWithTouches(UIView *view, NSSet *touches, NSString *mark)
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"hash" ascending:YES];
    NSArray *sortedTouches = [touches sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    NSMutableArray *touchMessages = [[NSMutableArray alloc] init];
    for (UITouch *touch in sortedTouches) {
        CGPoint point = [touch locationInView:view];
        NSString *touchedColor = touch.view.tag == kRedViewSpecialTag? @"R": @"W";
        NSString *touchMessage = [NSString stringWithFormat:@"(%f,%f)[%@][%@]",
                                  point.x, point.y, touchedColor, mark];
        [touchMessages addObject:touchMessage];
    }
    NSLog(@"<TOUCH-MESSAGE> %@", touchMessages);
}

@interface _TNTouchShowMessageGestureRecognizer : UIGestureRecognizer @end

@implementation TNTouchShowMessage
{
    UIView *_redView;
}

+ (NSString *)testName
{
    return @"show multi-touch message";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _redView = [self _newRedView];
    
    [self.view addSubview:_redView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addGestureRecognizer:[_TNTouchShowMessageGestureRecognizer new]];
}

- (UIView *)_newRedView
{
    UIEdgeInsets edgeInset = UIEdgeInsetsMake(210, 75, 75, 75);
    UIView *redView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.bounds, edgeInset)];
    redView.backgroundColor = [UIColor redColor];
    [redView setTag:kRedViewSpecialTag];
    return redView;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ShowMessageWithTouches(self.view, touches, @"began");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ShowMessageWithTouches(self.view, touches, @"ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    ShowMessageWithTouches(self.view, touches, @"cancelled");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    ShowMessageWithTouches(self.view, touches, @"moved");
}

@end

@implementation _TNTouchShowMessageGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ShowMessageWithTouches(self.view, touches, @"GR-began");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ShowMessageWithTouches(self.view, touches, @"GR-ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    ShowMessageWithTouches(self.view, touches, @"GR-cancelled");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    ShowMessageWithTouches(self.view, touches, @"GR-moved");
}

@end
