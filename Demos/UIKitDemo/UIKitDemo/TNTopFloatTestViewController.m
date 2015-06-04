//
//  TNTopFloatTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/4.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTopFloatTestViewController.h"

@interface TNTopFloatTestViewController ()
{
    UIView *_touchArea;
    UIView *_controlPanel;
}
@end

@implementation TNTopFloatTestViewController

+ (NSString *)testName
{
    return @"Top Float View Test";
}

- (NSString *)customControlName
{
    return @"**Custom**";
}

- (void)onTappedCustomControlItemButton
{
    // to be override.
}

- (void)onSetTargetRectangle:(CGRect)targetRect inView:(UIView *)view
{
    // to be override.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _makeTouchArea];
    [self _makeControlPanel];
    [self _moveTouchAreaWithIndex:0];
}

- (void)_makeTouchArea
{
    _touchArea = [[UIView alloc] initWithFrame:CGRectZero];
    _touchArea.backgroundColor = [UIColor redColor];
    [self.view addSubview:_touchArea];
}

- (void)_makeControlPanel
{
    _controlPanel = [[UIView alloc] initWithFrame:CGRectZero];
    [self _makeControlButtonFor:_controlPanel withTitle:@"on center" at:0];
    [self _makeControlButtonFor:_controlPanel withTitle:@"close to border" at:1];
    [self _makeControlButtonFor:_controlPanel withTitle:@"hold a corner" at:2];
    [self _makeControlButtonFor:_controlPanel withTitle:@"cover a side" at:3];
    [self _makeControlButtonFor:_controlPanel withTitle:@"full-screen" at:4];
    [self _makeControlButtonFor:_controlPanel withTitle:[self customControlName] at:5];
    [_touchArea addSubview:_controlPanel];
}

- (void)_makeControlButtonFor:(UIView *)panel withTitle:(NSString *)title at:(NSUInteger)index
{
    UIButton *controlButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [panel addSubview:controlButton];
    
    static const CGFloat ButtonStartYLocation = 15;
    static const CGFloat ButtonStartXLocation = 10;
    static const CGFloat ButtonWidth = 140;
    static const CGFloat ButtonHeight = 30;
    static const CGFloat ButtonInterval = 10;
    
    controlButton.frame = CGRectMake(ButtonStartXLocation,
                                     ButtonStartYLocation + index*(ButtonHeight + ButtonInterval),
                                     ButtonWidth, ButtonHeight);
    panel.frame = CGRectMake(0, 0,
                             2*ButtonStartXLocation + ButtonWidth,
                             (index + 1)*ButtonHeight + (index + 1)*ButtonInterval + ButtonStartYLocation);
    
    controlButton.tag = index;
    [controlButton setTitle:title forState:UIControlStateNormal];
    [controlButton setBackgroundColor:[UIColor whiteColor]];
    [controlButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [controlButton addTarget:self action:@selector(_onTappedControlButton:)
            forControlEvents:UIControlEventTouchUpInside];
}


- (void)_onTappedControlButton:(UIButton *)controlButton
{
    [self _moveTouchAreaWithIndex:controlButton.tag];
}

- (void)_moveTouchAreaWithIndex:(NSUInteger)index
{
    MoveForward moveForward = [self _randomMoveForward];
    [self _moveTouchAreaWithIndex:index withMoveForward:moveForward];
    [self _settingControlPanelOnCenterOfTouchArea];
    [self onSetTargetRectangle:_touchArea.frame inView:self.view];
}


- (void)_moveTouchAreaWithIndex:(NSUInteger)index withMoveForward:(MoveForward)moveForward
{
    switch (index) {
        case 0:
            [self _moveTouchAreaToCenter];
            break;
            
        case 1:
            [self _moveTouchAreaCloseToBorderWithForward:moveForward];
            break;
            
        case 2:
            [self _moveTouchAreaHoldACornerWithForward:moveForward];
            break;
            
        case 3:
            [self _moveTouchCoverASideWithForward:moveForward];
            break;
            
        case 4:
            [self _moveTouchFullScreen];
            break;
            
        case 5:
            [self onTappedCustomControlItemButton];
            break;
    }
}

- (void)_moveTouchAreaToCenter
{
    _touchArea.frame = CGRectMake(0, 0, _controlPanel.bounds.size.width, _controlPanel.bounds.size.height);
    _touchArea.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
}


- (void)_moveTouchAreaCloseToBorderWithForward:(MoveForward)moveForward
{
    CGFloat width = _controlPanel.bounds.size.width;
    CGFloat height = _controlPanel.bounds.size.height;
    _touchArea.frame = CGRectMake(0, 0, width, height);
    
    switch (moveForward) {
        case MoveForwardUp:
            _touchArea.center = CGPointMake(self.view.bounds.size.width/2, height/2);
            break;
            
        case MoveForwardDown:
            _touchArea.center = CGPointMake(self.view.bounds.size.width/2,
                                            self.view.bounds.size.height - height/2);
            break;
            
        case MoveForwardLeft:
            _touchArea.center = CGPointMake(width/2, self.view.bounds.size.height/2);
            break;
            
        case MoveForwardRight:
            _touchArea.center = CGPointMake(self.view.bounds.size.width - width/2,
                                            self.view.bounds.size.height/2);
            break;
            
    }
}

- (void)_moveTouchAreaHoldACornerWithForward:(MoveForward)moveForward
{
    CGFloat width = _controlPanel.bounds.size.width;
    CGFloat height = _controlPanel.bounds.size.height;
    
    switch (moveForward) {
        case MoveForwardUp:
            _touchArea.frame = CGRectMake(0, 0, width, height);
            break;
            
        case MoveForwardDown:
            _touchArea.frame = CGRectMake(self.view.bounds.size.width - width,
                                          self.view.bounds.size.height - height,
                                          width, height);
            break;
            
        case MoveForwardLeft:
            _touchArea.frame = CGRectMake(0, self.view.bounds.size.height - height, width, height);
            break;
            
        case MoveForwardRight:
            _touchArea.frame = CGRectMake(self.view.bounds.size.width - width, 0, width, height);
            break;
            
    }
}

- (void)_moveTouchCoverASideWithForward:(MoveForward)moveForward
{
    CGFloat width = _controlPanel.bounds.size.width;
    CGFloat height = _controlPanel.bounds.size.height;
    
    switch (moveForward) {
        case MoveForwardUp:
            _touchArea.frame = CGRectMake(0, 0, self.view.bounds.size.width, height);
            break;
            
        case MoveForwardDown:
            _touchArea.frame = CGRectMake(0, self.view.bounds.size.height - height,
                                          self.view.bounds.size.width, height);
            break;
            
        case MoveForwardLeft:
            _touchArea.frame = CGRectMake(0, 0, width, self.view.bounds.size.height);
            break;
            
        case MoveForwardRight:
            _touchArea.frame = CGRectMake(self.view.bounds.size.width - width, 0,
                                          width, self.view.bounds.size.height);
            break;
            
    }
}

- (void)_moveTouchFullScreen
{
    _touchArea.frame = self.view.bounds;
}

- (void)_settingControlPanelOnCenterOfTouchArea
{
    _controlPanel.center = CGPointMake(_touchArea.bounds.size.width/2, _touchArea.bounds.size.height/2);
}

- (MoveForward)_randomMoveForward
{
    static u_int32_t lastRandomNumber = 0;
    u_int32_t currentRandomNumber;
    do {
        currentRandomNumber = arc4random()%4;
    } while (currentRandomNumber == lastRandomNumber);
    lastRandomNumber = currentRandomNumber;
    return currentRandomNumber;
}

@end
