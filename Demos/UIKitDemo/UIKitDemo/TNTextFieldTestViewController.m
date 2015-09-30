//
//  TNTextFieldTestViewController.m
//  UIKitDemo
//
//  Created by Chen Yonghui on 5/7/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTextFieldTestViewController.h"

@interface TNTextFieldTestViewController ()
@property (nonatomic, strong) UITextField *field2;
@end

@implementation TNTextFieldTestViewController
{
    NSArray *_fieldArray;
    NSUInteger _originalSelectedIndex;
}

+ (NSString *)testName
{
    return @"UITextField Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0,250,500,44)];
    field.placeholder = @"Type UserName here.";
    [self.view addSubview:field];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(0,350,250,44)];
    field2.placeholder = @"Type Password here.";
    self.field2 = field2;
    [self.view addSubview:field2];
    
    _fieldArray = @[field, field2];
    _originalSelectedIndex = NSUIntegerMax;
    
    NSArray *items = @[@"field", @"field2", @"null"];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    segmentedControl.frame = CGRectMake(0, 150, 500, 50);
    
    [segmentedControl addTarget:self action:@selector(_onChangedSegmentedIndex:)
               forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
}

- (void)_onChangedSegmentedIndex:(UISegmentedControl *)segmentedControl
{
    NSUInteger index = segmentedControl.selectedSegmentIndex;
    
    UITextField *originalText = [self _textFieldAt:_originalSelectedIndex];
    UITextField *text = [self _textFieldAt:index];
    
    if (originalText) {
        [originalText resignFirstResponder];
    }
    if (text) {
        [text becomeFirstResponder];
    }
    _originalSelectedIndex = index;
}

- (UITextField *)_textFieldAt:(NSUInteger)index
{
    if (index >= _fieldArray.count) {
        return nil;
    }
    return [_fieldArray objectAtIndex:index];
}

@end
