//
//  TNMenuNotificationTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/5/24.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNMenuNotificationTestViewController.h"

@interface TNMenuNotificationTestViewController ()

@end

@implementation TNMenuNotificationTestViewController

+ (NSString *)testName
{
    return @"Menu Notification Test";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _configureTapEvent];
    [self _configureNotifications];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    if (@selector(_onTappedMenuItem:) == action) {
        return YES;
    }
    return NO;
}

- (void)_configureMenuController
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:self.view.bounds inView:self.view];
    [menuController setMenuItems:@[
                                   [self _createMenuItemWithTitle:@"Copy"],
                                   [self _createMenuItemWithTitle:@"Cut"],
                                   [self _createMenuItemWithTitle:@"Paste"],
                                   ]];
}

- (void)_printMenuControllerState
{
    CGRect menuFrame = [[UIMenuController sharedMenuController] menuFrame];
    NSLog(@"menu controller's menuFrame == [%f, %f, %f, %f]", menuFrame.origin.x, menuFrame.origin.y,
                                                              menuFrame.size.width, menuFrame.size.height);
}

- (void)_configureTapEvent
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(_onTappedSpace:)];
    [recognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:recognizer];
}

- (void)_configureNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (NSString *notificationName in [self _notificationNames]) {
        [center addObserver:self selector:@selector(_onNotifiyWithMessage:)
                       name:notificationName object:nil];
    }
}

- (NSArray *)_notificationNames
{
    static NSArray *notificationNames;
    if (!notificationNames) {
        notificationNames = @[
                              UIMenuControllerWillShowMenuNotification,
                              UIMenuControllerDidShowMenuNotification,
                              UIMenuControllerWillHideMenuNotification,
                              UIMenuControllerDidHideMenuNotification,
                              UIMenuControllerMenuFrameDidChangeNotification,
                              ];
    }
    return notificationNames;
}

- (UIMenuItem *)_createMenuItemWithTitle:(NSString *)title
{
    return [[UIMenuItem alloc] initWithTitle:title action:@selector(_onTappedMenuItem:)];
}

- (void)_onTappedMenuItem:(id)sender
{
    NSLog(@"tapped menu item %@", sender);
}

- (void)_onTappedSpace:(id)sender
{
    [self _configureMenuController];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    [[UIMenuController sharedMenuController] update];
    [self _printMenuControllerState];
}

- (void)_onNotifiyWithMessage:(id)notification
{
    NSLog(@"notify %@", [notification name]);
}

@end
