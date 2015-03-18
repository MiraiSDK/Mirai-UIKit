//
//  TNProgressTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/16.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNProgressTestViewController.h"
#import "TNComponentCreator.h"
#import "TNChangedColorButton.h"
#import <UIKit/UIKit.h>

@interface TNProgressTestViewController ()
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSMutableArray *changePreogressValueButtons;
@property (nonatomic, strong) NSMutableArray *changePreogressValues;
@property BOOL willPlayAnimationWhenSetProgressValue;
@end

@implementation TNProgressTestViewController

+ (NSString *)testName
{
    return @"UIProgress Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _makeChangeTintColorButtons];
    [self _makeProgressViewWithStyle:UIProgressViewStyleDefault];
    [self _makeChangeProgressValueButtons];
    [self _makeChangeProgressViewStyleButtons];
}

- (void)_makeProgressViewWithStyle:(UIProgressViewStyle)style
{
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:style];
    self.progressView.frame = CGRectMake(5, 170, 200, 35);
    [self.view addSubview:self.progressView];
}

- (void)_clearProgressView
{
    [self.progressView removeFromSuperview];
}

- (void)_makeChangeProgressValueButtons
{
    [TNComponentCreator makeSwitchItemWithTitle:@"setProgressAnimation" at:185 withControl:self
                                         action:@selector(_onChangeSetProgressValueAnimationSwitch:)];
    self.willPlayAnimationWhenSetProgressValue = YES;
    
    self.changePreogressValueButtons = [[NSMutableArray alloc] init];
    self.changePreogressValues = [[NSMutableArray alloc] init];
    for (NSUInteger i=0; i<5; i++) {
        float value = i/4.0;
        NSString *title = [NSString stringWithFormat:@"p=%li/4", i];
        UIButton *button = [TNComponentCreator createButtonWithTitle:title
                                                           withFrame:CGRectMake(50*i + 5, 240, 45, 30)];
        [self.view addSubview:button];
        [button addTarget:self
                   action:@selector(_onClickChangeProgressValueButton:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self.changePreogressValueButtons insertObject:button atIndex:i];
        [self.changePreogressValues insertObject:[NSNumber numberWithFloat:value] atIndex:i];
    }
}

- (void)_makeChangeProgressViewStyleButtons
{
    UIButton *defaultButton = [TNComponentCreator createButtonWithTitle:@"StyleDefault"
                                                              withFrame:CGRectMake(5, 290, 125, 25)];
    UIButton *barButton = [TNComponentCreator createButtonWithTitle:@"StyleBar"
                                                           withFrame:CGRectMake(140, 290, 125, 25)];
    defaultButton.backgroundColor = [UIColor redColor];
    barButton.backgroundColor = [UIColor blueColor];
    
    [defaultButton addTarget:self action:@selector(_onClickChangeDefaultStyleButton:)
            forControlEvents:UIControlEventTouchUpInside];
    [barButton addTarget:self action:@selector(_onClickChangeBarStyleButton:)
        forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:defaultButton];
    [self.view addSubview:barButton];
}

- (void)_makeChangeTintColorButtons
{
    UIButton *progressColorButton = [[TNChangedColorButton alloc] initWithFrame:CGRectMake(5, 320, 125, 25) whenColorChanged:^(UIColor *color) {
        self.progressView.progressTintColor = color;
    }];
    UIButton *trackColorButton = [[TNChangedColorButton alloc] initWithFrame:CGRectMake(135, 320, 125, 25) whenColorChanged:^(UIColor *color) {
        self.progressView.trackTintColor = color;
    }];
    [progressColorButton setTitle:@"progressTintColor" forState:UIControlStateNormal];
    [trackColorButton setTitle:@"trackTintColor" forState:UIControlStateNormal];
    
    [self.view addSubview:progressColorButton];
    [self.view addSubview:trackColorButton];
}

- (void)_onClickChangeProgressValueButton:(id)sender
{
    [self.progressView setProgress:[self _getProgressValueWithButton:(UIButton *)sender]
                          animated:self.willPlayAnimationWhenSetProgressValue];
}

- (void)_onChangeSetProgressValueAnimationSwitch:(id)sender
{
    self.willPlayAnimationWhenSetProgressValue = !self.willPlayAnimationWhenSetProgressValue;
}

- (void)_onClickChangeDefaultStyleButton:(id)sender
{
    [self _clearProgressView];
    [self _makeProgressViewWithStyle:UIProgressViewStyleDefault];
}

- (void)_onClickChangeBarStyleButton:(id)sender
{
    [self _clearProgressView];
    [self _makeProgressViewWithStyle:UIProgressViewStyleBar];
}

- (float)_getProgressValueWithButton:(UIButton *)button
{
    for (NSUInteger i=0; i<self.changePreogressValueButtons.count; ++i) {
        if ([self.changePreogressValueButtons objectAtIndex:i] == button) {
            return [(NSNumber *)[self.changePreogressValues objectAtIndex:i] floatValue];
        }
    }
    return NAN;
}

@end
