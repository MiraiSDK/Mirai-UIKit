//
//  TNSliderTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/2/14.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//
#import "TNSliderTestViewController.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TNSliderTestViewController()
@property (nonatomic, strong) UISlider *mainSlider;
@property (nonatomic, strong) UISwitch *continousSwitch;
@property (nonatomic, strong) UILabel *sliderLabel;
@end

@implementation TNSliderTestViewController

+ (NSString *)testName
{
    return @"UISlider Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _makeMainSlider];
    [self _makeContinuousSwitch];
    [self _makeSetTintColorButtons];
    [self _makeSetThumbImageButton];
    [self _makeSliderValueLabel];
}

- (void)_makeMainSlider
{
    self.mainSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 150, 250, 70)];
    self.mainSlider.continuous = NO;
    [self.mainSlider addTarget:self
                        action:@selector(_onSliderValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.mainSlider];
}

- (void)_makeContinuousSwitch
{
    self.continousSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, 250, 0, 0)];
    [self.continousSwitch addTarget:self
                             action:@selector(_onContinousSwitchValueChanged:)
                   forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.continousSwitch];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 250, 200, 45)];
    titleLabel.text = @"UISlider's continous.";
    
    [self.view addSubview:titleLabel];
}

- (void)_makeSetTintColorButtons
{
    UIButton *thumbColorButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 300, 100, 50)];
    thumbColorButton.backgroundColor = [UIColor redColor];
    [thumbColorButton addTarget:self
                         action:@selector(_onClickThumbColorButton:)
               forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *trackColorButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 300, 100, 50)];
    trackColorButton.backgroundColor = [UIColor greenColor];
    [trackColorButton addTarget:self
                         action:@selector(_onClickTrackColorButton:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:thumbColorButton];
    [self.view addSubview:trackColorButton];
}

- (void)_makeSetThumbImageButton
{
    UIButton *thumbImageButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 370, 100, 50)];
    thumbImageButton.backgroundColor = [UIColor yellowColor];
    [thumbImageButton addTarget:self
                         action:@selector(_onClickThumbImageButton:)
               forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 370, 200, 45)];
    titleLabel.text = @"setThumbImage.";
    
    [self.view addSubview:thumbImageButton];
    [self.view addSubview:titleLabel];
}

- (void)_makeSliderValueLabel
{
    self.sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 420, 200, 45)];
    self.sliderLabel.text = @"wait for drag...";
    
    [self.view addSubview:self.sliderLabel];
}

- (void)_onSliderValueChanged:(id)render
{
    NSLog(@"");
    NSLog(@"============");
    NSLog(@"value of UISlider was changed.");
    NSLog(@"============");
    NSLog(@"");
    
    self.sliderLabel.text = [[NSString alloc] initWithFormat:@"value of UISlider == %f", self.mainSlider.value];
}

- (void)_onContinousSwitchValueChanged:(id)render
{
    self.mainSlider.continuous = self.continousSwitch.on;
}

- (void)_onClickThumbColorButton:(id)render
{
    self.mainSlider.thumbTintColor = [UIColor redColor];
}

- (void)_onClickTrackColorButton:(id)render
{
    self.mainSlider.minimumTrackTintColor = [UIColor greenColor];
    self.mainSlider.maximumTrackTintColor = [UIColor greenColor];
}

- (void)_onClickThumbImageButton:(id)render
{
    UIImage *image = [UIImage imageNamed:@"loveheart.png"];
    [self.mainSlider setThumbImage:image forState:UIControlStateNormal];
}

@end
