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

#import "UIBarButtonItem.h"
#import "UIView.h"

@implementation UIBarButtonItem {
    BOOL _isSystemItem;
    NSString *_title;
    UIImage *_image;
    
    UIBarButtonSystemItem _systemItem;
    UIBarButtonItemStyle _style;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isSystemItem = NO;
        _style = UIBarButtonItemStylePlain;
    }
    return self;
}

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action
{
    if ((self=[self init])) {
        _isSystemItem = YES;
        _systemItem = systemItem;
        
        _target = target;
        _action = action;
    }
    return self;
}

- (id)initWithCustomView:(UIView *)customView
{
    if ((self=[self init])) {
        _customView = customView;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
    if ((self=[self init])) {
        _title = title;
        _style = style;
        _target = target;
        _action = action;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
    if ((self=[self init])) {
        _image = image;
        _style = style;
        _target = target;
        _action = action;
    }
    return self;
}

- (UIView *)customView
{
    return _isSystemItem? nil : _customView;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
}

- (UIImage *)backgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
}

- (UIImage *)backgroundImageForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)setBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
}

- (CGFloat)backgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return 0.0f;
}

- (void)setTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
}

- (UIOffset)titlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return UIOffsetZero;
}

- (void)setBackButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
}

- (UIImage *)backButtonBackgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (void)setBackButtonTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
}

- (UIOffset)backButtonTitlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return UIOffsetZero;
}

- (void)setBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics
{
        NS_UNIMPLEMENTED_LOG;
}

- (CGFloat)backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics
{
    NS_UNIMPLEMENTED_LOG;
    return 0.0f;
}

@end
