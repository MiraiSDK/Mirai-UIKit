//
//  TNTestCaseHelperButton.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/7.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTestCaseHelperButton.h"

#define DefaultResetStateWaitTime 1.8

typedef enum {
    ButtonStateWaitForTest = 0,
    ButtonStateTestError = 1,
    ButtonStateTestPass = 2
} ButtonState;

@interface TNTestCaseHelperButton()
@property (nonatomic, strong) UIButton *subButton;
@property (nonatomic, strong) NSTimer *resetWaitTimer;
@property (nonatomic) ButtonState buttonState;
@property (nonatomic) int foundTestFailCount;
@property (nonatomic) int foundTestCount;
@end

@implementation TNTestCaseHelperButton

- (instancetype)initWithPosition:(CGPoint)point
{
    if (self = ([super initWithFrame:CGRectMake(point.x, point.y, 100, 50)])) {
        self.subButton = [self _createSubButton];
        self.buttonState = ButtonStateWaitForTest;
        [self.subButton addTarget:self action:@selector(_onClickSubButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (UIButton *)_createSubButton
{
    UIButton *subButton = [UIButton buttonWithType:UIButtonTypeSystem];
    subButton.frame = CGRectMake(0, 0, 100, 50);
    [self addSubview:subButton];
    return subButton;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.subButton.frame = frame;
}

- (void)setButtonState:(ButtonState)buttonState
{
    switch (buttonState) {
        case ButtonStateWaitForTest:
            self.subButton.backgroundColor = [UIColor whiteColor];
            [self.subButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.subButton setTitle:@"Test Case" forState:UIControlStateNormal];
            break;
            
        case ButtonStateTestError:
            self.subButton.backgroundColor = [UIColor redColor];
            [self.subButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.subButton setTitle:@"Fail!" forState:UIControlStateNormal];
            break;
            
        case ButtonStateTestPass:
            self.subButton.backgroundColor = [UIColor greenColor];
            [self.subButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.subButton setTitle:@"Pass" forState:UIControlStateNormal];
            break;
    }
    [self.subButton setEnabled:(buttonState == ButtonStateWaitForTest)];
    
    _buttonState = buttonState;
}

- (void)_onClickSubButton:(id)sender
{
    if (self.buttonState != ButtonStateWaitForTest) {
        return;
    }
    self.buttonState = [self _testAndCheckPassAll];
    self.resetWaitTimer = [NSTimer scheduledTimerWithTimeInterval:DefaultResetStateWaitTime
                                                           target:self
                                                         selector:@selector(_toResetState)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)_toResetState
{
    self.buttonState = ButtonStateWaitForTest;
    [self.resetWaitTimer invalidate];
    self.resetWaitTimer = nil;
}
                    
                          
- (ButtonState)_testAndCheckPassAll
{
    NSLog(@"\n\nstart test...");
    self.foundTestCount = 0;
    self.foundTestFailCount = 0;
    self.invokeTestCaseBlock(self);
    
    BOOL resultCode = self.foundTestFailCount <= 0;
    NSString *resultDescription = resultCode? @"pass": @"fail";
    
    NSLog(@"%@, all %i pass %i.", resultDescription, self.foundTestCount, (self.foundTestCount - self.foundTestFailCount));
    
    return resultCode? ButtonStateTestPass: ButtonStateTestError;
}

- (void)assertAny:(id)target
{
    [self assertAny:target forTest:@"check any."];
}

- (void)assertAny:(id)target forTest:(NSString *)description
{
    [self assert:(target != nil) forTest:description];
}

- (void)assertNil:(id)target
{
    [self assertNil:target forTest:@"check nil"];
}

- (void)assertNil:(id)target forTest:(NSString *)description
{
    [self assert:(target == nil) forTest:description];
}

- (void)assert:(BOOL)value
{
    [self assert:value forTest:@"check YES."];
}

- (void)assert:(BOOL)value forTest:(NSString *)description
{
    if (!value) {
        NSLog(@"[ERROR] %@", description);
        self.foundTestFailCount++;
    }
    self.foundTestCount++;
}

@end
