//
//  TNGestureEffectTouch.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/8/21.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNGestureEffectTouch.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface _TNGestureEffectTouchView : UIView @end
@interface _TNGestureEffectTouchGestureReconizer : UITapGestureRecognizer @end

@implementation TNGestureEffectTouch
{
    UIGestureRecognizer *_gestureRecognizer;
}
+ (NSString *)testName
{
    return @"gesture effect touch callback";
}

- (void)loadView
{
    self.view = [_TNGestureEffectTouchView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _gestureRecognizer = [[_TNGestureEffectTouchGestureReconizer alloc] init];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addGestureRecognizer:_gestureRecognizer];
    [self _makeDelayTouchSwitches];
}

- (void)_onTapped:(id)sender
{
    NSLog(@"on tapped!!!");
}

- (void)_makeDelayTouchSwitches
{
    UIView *delayTouchSwitchesContainer = [[UIView alloc] initWithFrame:CGRectMake(5, 125, 100, 100)];
    
    UISwitch *delaysTouchesBeganSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    UISwitch *delaysTouchesEndedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 50, 0, 0)];
    
    delaysTouchesBeganSwitch.on = _gestureRecognizer.delaysTouchesBegan;
    delaysTouchesEndedSwitch.on = _gestureRecognizer.delaysTouchesEnded;
    
    [delaysTouchesBeganSwitch addTarget:self action:@selector(_onDelaysTouchesBeganSwitchChanged:)
                       forControlEvents:UIControlEventValueChanged];
    
    [delaysTouchesEndedSwitch addTarget:self action:@selector(_onDelaysTouchesEndedSwitchChanged:)
                       forControlEvents:UIControlEventValueChanged];
    
    [delayTouchSwitchesContainer addSubview:delaysTouchesBeganSwitch];
    [delayTouchSwitchesContainer addSubview:delaysTouchesEndedSwitch];
    
    [delayTouchSwitchesContainer setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:delayTouchSwitchesContainer];
}

- (void)_onDelaysTouchesBeganSwitchChanged:(UISwitch *)switchItem
{
    _gestureRecognizer.delaysTouchesBegan = switchItem.on;
}

- (void)_onDelaysTouchesEndedSwitchChanged:(UISwitch *)switchItem
{
    _gestureRecognizer.delaysTouchesEnded = switchItem.on;
}

@end

@implementation _TNGestureEffectTouchView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint([touch locationInView:self]));
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint([touch locationInView:self]));
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint([touch locationInView:self]));
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSLog(@"%s %@", __FUNCTION__, NSStringFromCGPoint([touch locationInView:self]));
}

@end

static const NSUInteger RegicgnizerNeedMovedCount = 25;

@implementation _TNGestureEffectTouchGestureReconizer
{
    NSUInteger _movedCount;
}

- (void)reset
{
    [super reset];
    
    NSLog(@"========= reset ==========");
    
    _movedCount = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"recognizer touchesBegan callback");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"recognizer touchesMoved callback");
    
    if (++_movedCount <= RegicgnizerNeedMovedCount) {
        return;
    }
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"recognizer touchesEnded callback");
    
    if (_movedCount <= RegicgnizerNeedMovedCount) {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"recognizer touchesCancelled callback");
}

@end
