//
//  UIPopoverFloatView.m
//  UIKit
//
//  Created by TaoZeyu on 15/6/6.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPopoverFloatView.h"
#import "UIPositionOnRect.h"

@implementation UIPopoverFloatView
{
    UIPopoverController *_parent;
}

- (instancetype)initWithParent:(UIPopoverController *)parent withContainer:(UIView *)container
{
    if (self = [super initWithContainer:container]) {
        _parent = parent;
    }
    return self;
}

- (NSArray *)testPositionOnBorderDirectionList
{
    NSDictionary *arrowDirectionDictionary;
    if (!arrowDirectionDictionary) {
        arrowDirectionDictionary = @{
                                     @(UIPopoverArrowDirectionUp):
                                         @[@(UIPositionOnRectDirectionUp)],
                                     @(UIPopoverArrowDirectionDown):
                                         @[@(UIPositionOnRectDirectionDown)],
                                     @(UIPopoverArrowDirectionLeft):
                                         @[@(UIPositionOnRectDirectionLeft)],
                                     @(UIPopoverArrowDirectionRight):
                                         @[@(UIPositionOnRectDirectionRight)],
                                     @(UIPopoverArrowDirectionAny):
                                         @[@(UIPositionOnRectDirectionUp),
                                           @(UIPositionOnRectDirectionDown),
                                           @(UIPositionOnRectDirectionLeft),
                                           @(UIPositionOnRectDirectionRight),],
                                     };
    }
    UIPopoverArrowDirection arrowDirection = [_parent popoverArrowDirection];
    NSArray *rs = [arrowDirectionDictionary objectForKey:@(arrowDirection)];
    NSLog(@"->%@ %@", rs, @(arrowDirection));
    return rs;
}

- (void)reciveMaskedTouch:(UITouch *)touch
{
    [self setVisible:NO animated:YES];
}

@end
