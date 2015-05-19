//
//  TNMenuPositionTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/18.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNMenuPositionTestViewController.h"

typedef enum {
    MoveForwardUp = 0,
    MoveForwardDown = 1,
    MoveForwardLeft = 2,
    MoveForwardRight = 3,
} MoveForward;

@interface TNMenuPositionTestViewController ()
@property (nonatomic) BOOL willShowMenu;
@property (nonatomic, strong) UIView *controlPanel;
@property (nonatomic, strong) UIView *touchArea;
@end

@implementation TNMenuPositionTestViewController

+ (NSString *)testName
{
    return @"Menu Position Test";
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
    [self _makeControlButtonFor:_controlPanel withTitle:@"**MENU**" at:5];
    [_touchArea addSubview:_controlPanel];
}

- (void)_replaceMenuVisible
{
    NSArray *menuItems = [self _createRandomMenuItems];
    [[UIMenuController sharedMenuController] setMenuItems:menuItems];
    self.willShowMenu = YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    if (@selector(_onTappedAnyItemOfMenuController:) == action) {
        return YES;
    }
    return NO;
}

- (void)setWillShowMenu:(BOOL)willShowMenu
{
    [[UIMenuController sharedMenuController] setMenuVisible:willShowMenu animated:YES];
    _willShowMenu = willShowMenu;
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
    [[UIMenuController sharedMenuController] setTargetRect:_touchArea.frame inView:self.view];
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
            [self _replaceMenuVisible];
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

- (NSArray *)_createRandomMenuItems
{
    NSMutableArray *items;
    do {
        items = [[NSMutableArray alloc] init];
        for (NSString *title in [self _getMenuItemsList]) {
            if (arc4random()%2 == 0) {
                [items addObject:[self _createMenuItemWithTitle:title]];
            }
        }
    } while (items.count <= 0);
    return items;
}

- (NSArray *)_getMenuItemsList
{
    static NSArray *list = nil;
    if (list == nil) {
        list = @[
                 @"Copy",
                 @"Paste",
                 @"Cut",
                 @"Drop",
                 ];
    }
    return list;
}

- (UIMenuItem *)_createMenuItemWithTitle:(NSString *)title
{
    return [[UIMenuItem alloc] initWithTitle:title
                                      action:@selector(_onTappedAnyItemOfMenuController:)];
}

- (void)_onTappedAnyItemOfMenuController:(id)sender
{
    self.willShowMenu = NO;
}

@end
