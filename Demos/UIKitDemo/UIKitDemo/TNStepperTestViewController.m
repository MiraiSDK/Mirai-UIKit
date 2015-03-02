//
//  TNStepperTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/2/27.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNStepperTestViewController.h"
#import "TNComponentCreator.h"
#import "TNChangedColorButton.h"

@interface TNStepperTestViewController ()
@property (nonatomic, strong) UIStepper *stepper;
@property (nonatomic, strong) UILabel *displayerLabel;
@end

@implementation TNStepperTestViewController

+ (NSString *)testName
{
    return @"UIStepper Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _makeStepper];
    [self _makeValueDisplayer];
    [self _makeSwitchItemList];
    [self _makeTintColorChangeButtons];
    [self _makeViewImageTestButtons];
    [self _makeSimulateButton];
    [self _makeErrorValueButton];
}

- (void)_makeStepper
{
    self.stepper = [[UIStepper alloc] initWithFrame:CGRectMake(50, 110, 400, 100)];
    [self.view addSubview:self.stepper];
}

- (void)_makeValueDisplayer
{
    self.displayerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 155, 300, 50)];
    self.displayerLabel.text = [self _getValueDisplayText];
    [self.view addSubview:self.displayerLabel];
    [self.stepper addTarget:self action:@selector(_onSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)_makeSwitchItemList
{
    [TNComponentCreator makeSwitchItemWithTitle:@"continous"
                                             at:185
                                    withControl:self
                                         action:@selector(_onSwitchContinousChanged:)];
    
    [TNComponentCreator makeSwitchItemWithTitle:@"autorepeat"
                                             at:210
                                    withControl:self
                                         action:@selector(_onSwitchAutorepeatChanged:)];
    
    [TNComponentCreator makeSwitchItemWithTitle:@"wraps"
                                             at:245
                                    withControl:self
                                         action:@selector(_onSwitchWrapsChanged:)];
}

- (void)_makeTintColorChangeButtons
{
    UIButton *changeTintColorButton = [[TNChangedColorButton alloc] initWithFrame:CGRectMake(50, 280, 100, 50) whenColorChanged:^(UIColor *color) {
        self.stepper.tintColor = color;
    }];
    [changeTintColorButton setTitle:@"tintColor" forState:UIControlStateNormal];
    [self.view addSubview:changeTintColorButton];
}

- (void)_makeViewImageTestButtons
{
    UIButton *changeDividerImageButton = [[TNChangedColorButton alloc] initWithFrame:CGRectMake(170, 280, 100, 50) whenColorChanged:^(UIColor *color) {
        UIImage *image = [TNComponentCreator createEllipseWithSize:CGSizeMake(5, 15) withColor:color];
        [self.stepper setDividerImage:image forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
    }];
    [changeDividerImageButton setTitle:@"setDividerImage" forState:UIControlStateNormal];
    [self.view addSubview:changeDividerImageButton];
}

- (void)_makeSimulateButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(50, 380, 100, 50);
    [self.view addSubview:button];
    
    [button setTitle:@"+" forState:UIControlStateNormal];
    [button setTintColor:[UIColor redColor]];
    
    [[button layer] setBorderWidth:4.0];
    [button.layer setBorderColor:[[UIColor redColor] CGColor]];
}

- (void)_makeErrorValueButton
{
    UIButton *maxinumValueErrorButton = [TNComponentCreator createButtonWithTitle:@"error maximunValue"
                                                                        withFrame:CGRectMake(50, 430, 100, 50)];
    [self.view addSubview:maxinumValueErrorButton];
    [maxinumValueErrorButton addTarget:self action:@selector(_onSetErrorMaximunValue:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *stepErrorButton = [TNComponentCreator createButtonWithTitle:@"error stepValue"
                                                                        withFrame:CGRectMake(220, 430, 100, 50)];
    [self.view addSubview:stepErrorButton];
    [stepErrorButton addTarget:self action:@selector(_onSetErrorStepValue:)
              forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *)_getValueDisplayText
{
    return [[NSString alloc] initWithFormat:@"value == %f", self.stepper.value];
}

- (void)_onSwitchValueChanged:(id)sender
{
    self.displayerLabel.text = [self _getValueDisplayText];
}

- (void)_onSwitchContinousChanged:(id)sender
{
    self.stepper.continuous = !self.stepper.continuous;
}

- (void)_onSwitchAutorepeatChanged:(id)sender
{
    self.stepper.autorepeat = !self.stepper.autorepeat;
}

- (void)_onSwitchWrapsChanged:(id)sender
{
    self.stepper.wraps = !self.stepper.wraps;
}

- (void)_onSetErrorMaximunValue:(id)sender
{
    NSLog(@"old maximunValue == %f", self.stepper.maximumValue);
    NSLog(@"old minimunValue == %f", self.stepper.minimumValue);
    NSLog(@"old value == %f", self.stepper.value);
    self.stepper.maximumValue = -1000.0;
    NSLog(@"new maximunValue == %f", self.stepper.maximumValue);
    NSLog(@"new minimunValue == %f", self.stepper.minimumValue);
    NSLog(@"new value == %f", self.stepper.value);
}

- (void)_onSetErrorStepValue:(id)sender
{
    NSLog(@"old stepValue == %f", self.stepper.stepValue);
    self.stepper.stepValue = -100;
    NSLog(@"new stepValue == %f", self.stepper.stepValue);
}

@end
