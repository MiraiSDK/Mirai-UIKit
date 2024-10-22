/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIApplication.h"

@class UIWindow, UIScreen, NSEvent, UIPopoverController;

typedef NS_ENUM(NSInteger, SCREEN_ORIENTATION) {
    SCREEN_ORIENTATION_UNSPECIFIED = -1,
    
    SCREEN_ORIENTATION_LANDSCAPE = 0,
    SCREEN_ORIENTATION_PORTRAIT = 1,
    SCREEN_ORIENTATION_USER = 2,
    SCREEN_ORIENTATION_BEHIND = 3,
    
    SCREEN_ORIENTATION_SENSOR = 4,
    SCREEN_ORIENTATION_NOSENSOR = 5,
    
    SCREEN_ORIENTATION_SENSOR_LANDSCAPE = 6,
    SCREEN_ORIENTATION_SENSOR_PORTRAIT = 7,
    SCREEN_ORIENTATION_REVERSE_LANDSCAPE = 8,
    SCREEN_ORIENTATION_REVERSE_PORTRAIT = 9,
    SCREEN_ORIENTATION_FULL_SENSOR = 10,
    SCREEN_ORIENTATION_USER_LANDSCAPE = 11,
    SCREEN_ORIENTATION_USER_PORTRAIT = 12,
    SCREEN_ORIENTATION_FULL_USER = 13,
    SCREEN_ORIENTATION_LOCKED = 14,
};

@interface UIApplication (UIPrivate)
- (UIWindow *)_cachedKeyWindow;
- (void)_setKeyWindow:(UIWindow *)newKeyWindow;
- (void)_windowDidBecomeVisible:(UIWindow *)theWindow;
- (void)_windowDidBecomeHidden:(UIWindow *)theWindow;
+ (BOOL)_isSharedInstanceReady;
- (BOOL)_sendGlobalKeyboardNSEvent:(NSEvent *)theNSEvent fromScreen:(UIScreen *)theScreen;	// checks for CMD-Return/Enter and returns YES if it was handled, NO if not
- (BOOL)_sendKeyboardNSEvent:(NSEvent *)theNSEvent fromScreen:(UIScreen *)theScreen;		// returns YES if it was handled within UIKit (first calls _sendGlobalKeyboardNSEvent:fromScreen:)
- (void)_sendMouseNSEvent:(NSEvent *)theNSEvent fromScreen:(UIScreen *)theScreen;
- (void)_cancelTouches;
- (void)_removeViewFromTouches:(UIView *)aView;
- (UIResponder *)_firstResponderForScreen:(UIScreen *)screen;
- (BOOL)_firstResponderCanPerformAction:(SEL)action withSender:(id)sender fromScreen:(UIScreen *)theScreen;
- (BOOL)_sendActionToFirstResponder:(SEL)action withSender:(id)sender fromScreen:(UIScreen *)theScreen;
- (NSUInteger)supportedInterfaceOrientations;

- (void)_appDidEnterBackground;
- (void)_appWillResignActive;
- (void)_appWillEnterForeground;
- (void)_appDidBecomeActive;
- (void)_appWillTerminate;
@end
