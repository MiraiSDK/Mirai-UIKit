//
//  UIResponder.m
//  UIKit
//
//  Created by Chen Yonghui on 12/6/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIResponder+UIPrivate.h"
#import "UIView.h"
#import "UIWindow.h"
#import "UIWindow+UIPrivate.h"

@implementation UIResponder
- (UIResponder *)nextResponder
{
    return nil;
}

- (UIWindow *)_responderWindow
{
    if ([self isKindOfClass:[UIView class]]) {
        return [(UIView *)self window];
    } else {
        return [[self nextResponder] _responderWindow];
    }
}

- (BOOL)isFirstResponder
{
    return ([[self _responderWindow] _firstResponder] == self);
}

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

- (BOOL)becomeFirstResponder
{
    if ([self isFirstResponder]) {
        return YES;
    } else {
        UIWindow *window = [self _responderWindow];
        UIResponder *firstResponder = [window _firstResponder];
        
        if (window && [self canBecomeFirstResponder]) {
            BOOL didResign = NO;
            
            if (firstResponder && [firstResponder canResignFirstResponder]) {
                didResign = [firstResponder resignFirstResponder];
            } else {
                didResign = YES;
            }
            
            if (didResign) {
                [window makeKeyWindow];		// not sure about this :/
                [window _setFirstResponder:self];
                
                // I have no idea how iOS manages this stuff, but here I'm modeling UIMenuController since it also uses the first
                // responder to do its work. My thinking is that if there were an on-screen keyboard, something here could detect
                // if self conforms to UITextInputTraits and UIKeyInput and/or UITextInput and then build/fetch the correct keyboard
                // and assign that to the inputView property which would seperate the keyboard and inputs themselves from the stuff
                // that actually displays them on screen. Of course on the Mac we don't need an on-screen keyboard, but there's
                // possibly an argument to be made for supporting custom inputViews anyway.
#warning needs fix
//                UIInputController *controller = [UIInputController sharedInputController];
//                controller.inputAccessoryView = self.inputAccessoryView;
//                controller.inputView = self.inputView;
//                [controller setInputVisible:YES animated:YES];
                
                return YES;
            }
        }
        
        return NO;
    }
}

- (BOOL)canResignFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    if ([self isFirstResponder]) {
        [[self _responderWindow] _setFirstResponder:nil];
#warning needs fix
//        [[UIInputController sharedInputController] setInputVisible:NO animated:YES];
    }
    
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ([[self class] instancesRespondToSelector:action]) {
        return YES;
    } else {
        return [[self nextResponder] canPerformAction:action withSender:sender];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"class:%@ %s",NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesCancelled:touches withEvent:event];
}

//- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event		{}
//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event		{}
//- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event	{}

- (UIView *)inputAccessoryView
{
    return nil;
}

- (UIView *)inputView
{
    return nil;
}

- (NSUndoManager *)undoManager
{
    return [[self nextResponder] undoManager];
}

@end
