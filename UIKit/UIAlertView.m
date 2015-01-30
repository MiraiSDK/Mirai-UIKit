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
#import "UILabel.h"

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
        if (otherButtonTitles) {
            va_list argumentList;
            va_start(argumentList, otherButtonTitles);
            id eachObject;
            while (eachObject = va_arg(argumentList, id)) {
                [_titles addObject: eachObject];
            }
            va_end(argumentList);
        }
    }
    return self;
}

- (void)show
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    alertWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    alertWindow.windowLevel = UIWindowLevelAlert;
    
    self.frame = CGRectMake(0, 0, 320, 200);
    self.center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2);
    self.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray * buttonArray = [NSMutableArray array];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(clickButon:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton sizeToFit];
    [buttonArray addObject:cancelButton];
    
    
    
    if (self.otherButtonTitle != nil) {
        UIButton * otherButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [otherButton setTitle:self.otherButtonTitle forState:UIControlStateNormal];
        [otherButton addTarget:self action:@selector(clickButon:) forControlEvents:UIControlEventTouchUpInside];
        [otherButton sizeToFit];
        [buttonArray addObject:otherButton];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]) {
            otherButton.enabled = [self.delegate alertViewShouldEnableFirstOtherButton:self];
        }
        
    }
    
    for (NSString * titleText in self.titles) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:titleText forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickButon:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        [buttonArray addObject:button];
    }
    
    CGFloat buttonWidth = self.frame.size.width / buttonArray.count;
    
    for (NSUInteger i = 0; i < buttonArray.count; ++i) {
        UIButton * button = buttonArray[i];
        CGRect f = button.frame;
        f.size.width = buttonWidth;
        f.origin.x = i * buttonWidth;
        f.origin.y = self.frame.size.height - f.size.height;
        button.frame = f;
        [self addSubview:button];
        button.tag = i;
    }
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    titleLabel.text = self.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 80)];
    messageLabel.text = self.message;
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:messageLabel];
    
//    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 450, 320, 200)];
//    label2.text = [NSString stringWithFormat:@"Label With Frame:%@,\n numberOfLines 0",NSStringFromCGRect(label2.frame)];
//    label2.textColor = [UIColor redColor];
//    label2.textAlignment = NSTextAlignmentRight;
//    label2.shadowColor = [UIColor greenColor];
//    label.shadowOffset = CGSizeMake(5, 5);
//    [self.view addSubview:label2];
    
//    [self addSubview:button];
    
    
    [alertWindow addSubview:self];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.delegate willPresentAlertView:self];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [alertWindow makeKeyAndVisible];
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
            [self.delegate didPresentAlertView:self];
        }
    }];
    
    self.alertWindow = alertWindow;
    
    [[self class] storeAlertView:self];
}

- (void)clickButon:(UIButton*)sender
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:sender.tag];
    }
    [self cleanupWithClickedButtonIndex:sender.tag animated:YES];
}

- (void)cleanupWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (animated) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
            [self.delegate alertView:self willDismissWithButtonIndex:buttonIndex];
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.alertWindow = nil;
            [[self class] removeAlertView:self];
        } completion:^(BOOL finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
                [self.delegate alertView:self didDismissWithButtonIndex:buttonIndex];
            }
            
        }];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
            [self.delegate alertView:self willDismissWithButtonIndex:buttonIndex];
        }
        self.alertWindow = nil;
        [[self class] removeAlertView:self];
        if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
            [self.delegate alertView:self didDismissWithButtonIndex:buttonIndex];
        }
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self cleanupWithClickedButtonIndex:buttonIndex animated:animated];
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
