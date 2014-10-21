//
//  UIAlertView.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIAlertView.h"

@implementation UIAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super init];
    return self;
}

- (void)show
{
    
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    
}


- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
    return nil;
}
@end
