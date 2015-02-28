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
}

- (void)_makeStepper
{
    self.stepper = [[UIStepper alloc] initWithFrame:CGRectMake(50, 100, 400, 50)];
    [self.view addSubview:self.stepper];
}

- (void)_makeValueDisplayer
{
    self.displayerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 125, 300, 50)];
    self.displayerLabel.text = [self _getValueDisplayText];
    [self.view addSubview:self.displayerLabel];
    [self.stepper addTarget:self action:@selector(_onSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)_makeSwitchItemList
{
    [TNComponentCreator makeSwitchItemWithTitle:@"continous"
                                             at:155
                                    withControl:self
                                         action:@selector(_onSwitchContinousChanged:)];
    
    [TNComponentCreator makeSwitchItemWithTitle:@"autorepeat"
                                             at:190
                                    withControl:self
                                         action:@selector(_onSwitchAutorepeatChanged:)];
    
    [TNComponentCreator makeSwitchItemWithTitle:@"wraps"
                                             at:215
                                    withControl:self
                                         action:@selector(onSwitchWrapsChanged:)];
}

- (void)_makeTintColorChangeButtons
{
    UIButton *changeTintColorButton = [[TNChangedColorButton alloc] initWithFrame:CGRectMake(50, 250, 100, 50) whenColorChanged:^(UIColor *color) {
        self.stepper.tintColor = color;
    }];
    [changeTintColorButton setTitle:@"tintColor" forState:UIControlStateNormal];
    [self.view addSubview:changeTintColorButton];
}

- (void)_makeViewImageTestButtons
{
    UIButton *changeDividerImageButton = [[TNChangedColorButton alloc] initWithFrame:CGRectMake(170, 250, 100, 50) whenColorChanged:^(UIColor *color) {
        UIImage *image = [TNComponentCreator createEllipseWithSize:CGSizeMake(5, 15) withColor:color];
        [self.stepper setDividerImage:image forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
    }];
    [changeDividerImageButton setTitle:@"setDividerImage" forState:UIControlStateNormal];
    [self.view addSubview:changeDividerImageButton];
}

- (void)_makeSimulateButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(50, 350, 100, 50);
    [self.view addSubview:button];
    
    [button setTitle:@"+" forState:UIControlStateNormal];
    [button setTintColor:[UIColor redColor]];
    
    [[button layer] setBorderWidth:4.0];
    [button.layer setBorderColor:[[UIColor redColor] CGColor]];
}

- (NSString *)_getValueDisplayText
{
    return [[NSString alloc] initWithFormat:@"value == %f", self.stepper.value];
}

- (void)_onSwitchValueChanged:(id)render
{
    self.displayerLabel.text = [self _getValueDisplayText];
}

- (void)_onSwitchContinousChanged:(id)render
{
    self.stepper.continuous = !self.stepper.continuous;
}

- (void)_onSwitchAutorepeatChanged:(id)render
{
    self.stepper.autorepeat = !self.stepper.autorepeat;
}

- (void)onSwitchWrapsChanged:(id)render
{
    self.stepper.wraps = !self.stepper.wraps;
}

@end
