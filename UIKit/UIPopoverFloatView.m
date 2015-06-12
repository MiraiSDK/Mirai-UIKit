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
    NSMutableArray *testList = [[NSMutableArray alloc] init];
    
    if (_presentArrowDirections & UIPopoverArrowDirectionUp) {
        [testList addObject:@(UIPositionOnRectDirectionUp)];
    }
    if (_presentArrowDirections & UIPopoverArrowDirectionDown) {
        [testList addObject:@(UIPositionOnRectDirectionDown)];
    }
    if (_presentArrowDirections & UIPopoverArrowDirectionLeft) {
        [testList addObject:@(UIPositionOnRectDirectionLeft)];
    }
    if (_presentArrowDirections & UIPopoverArrowDirectionRight) {
        [testList addObject:@(UIPositionOnRectDirectionRight)];
    }
    return testList;
}

- (void)reciveMaskedTouch:(UITouch *)touch
{
    if ([self _shouldDismissPopover]) {
        [self setVisible:NO animated:YES];
    }
}

- (BOOL)_shouldDismissPopover
{
    if (_parent.delegate) {
        return [_parent.delegate popoverControllerShouldDismissPopover:_parent];
    }
    return YES;
}

@end
