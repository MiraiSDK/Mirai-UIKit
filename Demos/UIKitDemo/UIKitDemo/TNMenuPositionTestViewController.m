//
//  TNMenuPositionTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/18.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNMenuPositionTestViewController.h"

@interface TNMenuPositionTestViewController ()
{
    BOOL _willShowMenu;
}
@end

@implementation TNMenuPositionTestViewController

+ (NSString *)testName
{
    return @"Menu Position Test";
}

- (NSString *)customControlName
{
    return @"**MENU**";
}

- (void)onTappedCustomControlItemButton
{
    NSArray *menuItems = [self _createRandomMenuItems];
    [[UIMenuController sharedMenuController] setMenuItems:menuItems];
    self.willShowMenu = YES;
}

- (void)onSetTargetRectangle:(CGRect)targetRect inView:(UIView *)view
{
    [[UIMenuController sharedMenuController] setTargetRect:targetRect inView:view];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    if (@selector(_onTappedAnyItemOfMenuController:) == action) {
        return YES;
    }
    return NO;
}

- (void)setWillShowMenu:(BOOL)willShowMenu
{
    [[UIMenuController sharedMenuController] setMenuVisible:willShowMenu animated:YES];
    _willShowMenu = willShowMenu;
}

- (NSArray *)_createRandomMenuItems
{
    NSMutableArray *items;
    do {
        items = [[NSMutableArray alloc] init];
        for (NSString *title in [self _getMenuItemsList]) {
            if (arc4random()%2 == 0) {
                [items addObject:[self _createMenuItemWithTitle:title]];
            }
        }
    } while (items.count <= 0);
    return items;
}

- (NSArray *)_getMenuItemsList
{
    static NSArray *list = nil;
    if (list == nil) {
        list = @[
                 @"Copy",
                 @"Paste",
                 @"Cut",
                 @"Drop",
                 ];
    }
    return list;
}

- (UIMenuItem *)_createMenuItemWithTitle:(NSString *)title
{
    return [[UIMenuItem alloc] initWithTitle:title
                                      action:@selector(_onTappedAnyItemOfMenuController:)];
}

- (void)_onTappedAnyItemOfMenuController:(id)sender
{
    self.willShowMenu = NO;
}

@end
