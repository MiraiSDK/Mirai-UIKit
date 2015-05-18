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
    
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0,150,500,44)];
    field.placeholder = @"Type UserName here.";
    [self.view addSubview:field];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(0,250,250,44)];
    field2.placeholder = @"Type Password here.";
    self.field2 = field2;
    [self.view addSubview:field2];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
