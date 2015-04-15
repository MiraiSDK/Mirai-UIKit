//
//  TNTextViewTestViewController.m
//  MiraiTests
//
//  Created by Chen Yonghui on 12/15/14.
//  Copyright (c) 2014 Shanghai Tinynetwork. All rights reserved.
//

#import "TNTextViewTestViewController.h"

@interface TNTextViewTestViewController ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation TNTextViewTestViewController

+ (NSString *)testName
{
    return @"UITextView Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect r = self.view.bounds;
    r.origin = CGPointMake(0,150);
    r.size.height = 500;
    UITextView *textview = [[UITextView alloc] initWithFrame:r];
    textview.text = @"Created by Chen Yonghui on 12/15/14.\n  Copyright (c) 2014 Shanghai Tinynetwork. All rights reserved.\n Text Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\nText Scroll\n";
    [self.view addSubview:textview];
    textview.textAlignment = UITextAlignmentCenter;
//    textview.textColor = [UIColor b];
//    textview.backgroundColor = [UIColor greenColor];
    self.textView = textview;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"showKeyboard" style:UIBarButtonItemStylePlain target:self action:@selector(debug_showKeyboard:)];
    self.navigationItem.rightBarButtonItems = @[item];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)debug_showKeyboard:(id)sender
{
    
}
@end
