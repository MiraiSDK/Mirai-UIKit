//
//  UIAlertView.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIAlertView.h"
#import "UIWindow.h"
#import "UIScreen.h"
#import "UIButton.h"

@interface UIAlertView ()
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSString *otherButtonTitle;
@end
@implementation UIAlertView

static NSMutableArray *_store = nil;
+ (void)storeAlertView:(UIAlertView *)alert
{
    if (_store == nil) {
        _store = [NSMutableArray array];
    }
    
    [_store addObject:alert];
}

+ (void)removeAlertView:(UIAlertView *)alert
{
    [_store removeObject:alert];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id <UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super init];
    if (self) {
        _title = [title copy];
        _message = [message copy];
        _delegate = delegate;
        _cancelButtonTitle = [cancelButtonTitle copy];
        _otherButtonTitle = [otherButtonTitles copy];
        _titles = [NSMutableArray array];
    }
    return self;
}

- (void)show
{
    UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    alertWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    alertWindow.windowLevel = UIWindowLevelAlert;
    
    self.frame = CGRectMake(0, 0, 320, 200);
    self.center = CGPointMake(self.alertWindow.bounds.size.width/2, self.alertWindow.bounds.size.height/2);
    self.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickButon:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    button.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height - button.bounds.size.height);
    
//    [self addSubview:button];
    
    [alertWindow addSubview:button];
    
    [alertWindow makeKeyAndVisible];
    self.alertWindow = alertWindow;
    
    [[self class] storeAlertView:self];
}

- (void)clickButon:(id)sender
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self cleanup];
}

- (void)cleanup
{
    self.alertWindow = nil;
    [[self class] removeAlertView:self];

}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self cleanup];
}


- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
    return nil;
}

- (NSInteger)addButtonWithTitle:(NSString *)title;
{
    return 0;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    return nil;
}

@end
