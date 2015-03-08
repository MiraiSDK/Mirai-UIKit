//
//  TNSegmentedControlTestViewControlViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/3/7.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNSegmentedControlTestViewControlViewController.h"
#import "TNTestCaseHelperButton.h"
#import "TNComponentCreator.h"

@interface TNSegmentedControlTestViewControlViewController ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UILabel *selectIndexLabel;
@end

@implementation TNSegmentedControlTestViewControlViewController

+ (NSString *)testName
{
    return @"UISegmentedControl Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _makeSegmentedControl];
    [self _makeTestCaseButton];
    [self _makeBoolValueTest];
    [self _makeSelectedIndexLabel];
    [self _makeSetWidthButtons];
}

- (void)_makeSegmentedControl
{
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        @"apple", @"pear", @"peach", @"strawberry"
    ]];
    self.segmentedControl.frame = CGRectMake(5, 80, 200, 50);
    [self.view addSubview:self.segmentedControl];
}

- (void)_makeTestCaseButton
{
    TNTestCaseHelperButton *button = [[TNTestCaseHelperButton alloc] initWithPosition:CGPointMake(215, 80)];
    [self.view addSubview:button];
    button.invokeTestCaseBlock = ^(TNTestCaseHelperButton *helper) {
        [self _testTitles:helper];
        [self _testInsertAndRemove:helper];
    };
}

- (void)_makeBoolValueTest
{
    [TNComponentCreator makeSwitchItemWithTitle:@"momentary"  at:140
                                    withControl:self action:@selector(_onSwitchMomentary:)];
    [TNComponentCreator makeSwitchItemWithTitle:@"apportionsSegmentWidthsByContent" at:180
                                    withControl:self action:@selector(_onApportionsSegmentWidthsByContent:)];
}

- (void)_makeSelectedIndexLabel
{
    self.selectIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 220, 400, 32)];
    self.selectIndexLabel.text = @"wait to select segment.";
    [self.view addSubview:self.selectIndexLabel];
    
    [self.segmentedControl addTarget:self action:@selector(_onValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)_makeSetWidthButtons
{
    UIButton *button = [TNComponentCreator createButtonWithTitle:@"set width"
                                                       withFrame:CGRectMake(5, 270, 100, 32)];
    [button addTarget:self action:@selector(_onClickSetWidth:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)_testTitles:(TNTestCaseHelperButton *)helper
{
    NSString *format = @"title(%li)";
    for (NSInteger i=0; i<self.segmentedControl.numberOfSegments; i++) {
        NSString *title = [[NSString alloc] initWithFormat:format, i];
        [self.segmentedControl setTitle:title forSegmentAtIndex:i];
    }
    for (NSInteger i=0; i<self.segmentedControl.numberOfSegments; i++) {
        NSString *title = [[NSString alloc] initWithFormat:format, i];
        NSString *segmentedTitle = [self.segmentedControl titleForSegmentAtIndex:i];
        [helper assert:[segmentedTitle isEqualToString:title] forTest:@"test titles."];
    }
}

- (void)_testInsertAndRemove:(TNTestCaseHelperButton *)helper
{
    NSString *title = @"inserted";
    NSInteger oldNumber = self.segmentedControl.numberOfSegments;
    
    [self.segmentedControl insertSegmentWithTitle:title atIndex:2 animated:NO];
    [helper assert:[title isEqualToString:[self.segmentedControl titleForSegmentAtIndex:2]] forTest:@"test insert"];
    [helper assert:self.segmentedControl.numberOfSegments == oldNumber + 1 forTest:@"test insert number."];
    
    [self.segmentedControl removeSegmentAtIndex:2 animated:NO];
    [helper assert:![title isEqualToString:[self.segmentedControl titleForSegmentAtIndex:2]] forTest:@"test remove"];
    [helper assert:self.segmentedControl.numberOfSegments == oldNumber forTest:@"test remove number."];
}

- (void)_onSwitchMomentary:(id)sender
{
    self.segmentedControl.momentary = !self.segmentedControl.momentary;
}

- (void)_onApportionsSegmentWidthsByContent:(id)sender
{
    self.segmentedControl.apportionsSegmentWidthsByContent = !self.segmentedControl.apportionsSegmentWidthsByContent;
}

- (void)_onValueChanged:(id)sender
{
    self.selectIndexLabel.text = [NSString stringWithFormat:@"selectedSegmentIndex == %li", self.segmentedControl.selectedSegmentIndex];
}

- (void)_onClickSetWidth:(id)sender
{
    [self.segmentedControl setWidth:100 forSegmentAtIndex:1];
    NSLog(@"segementedControl.widthAt[1] == %f", [self.segmentedControl widthForSegmentAtIndex:1]);
}

@end
