//
//  UISwitch.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISwitch.h"
#import "NSStringDrawing.h"
#import "UIGraphics.h"
#import "UILabel.h"

#define ButtonAnimationNeedFrames 6
#define LineWith 2.0



@interface UISwitch()
@property CGFloat buttonLocation;
@property NSInteger currentFrameCount;
@property BOOL isPlayingAnimation;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation UISwitch

+ (BOOL)isUnimplemented
{
    return NO;
}

+ (CGColorRef)_OnBackgroudColor
{
    static CGColorRef color;
    if (color == nil) {
        color = CGColorCreateGenericRGB(0.2, 0.7, 0.2, 1);
    }
    return color;
}

+ (CGColorRef)_OffBackgroudColor
{
    static CGColorRef color;
    if (color == nil) {
        color = CGColorCreateGenericRGB(0, 1, 0, 1);
    }
    return color;
}

+ (CGColorRef)_LineColor
{
    static CGColorRef color;
    if (color == nil) {
        color = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 1);
    }
    return color;
}

+ (CGColorRef)_ButtonColor
{
    static CGColorRef color;
    if (color == nil) {
        color = CGColorCreateGenericRGB(1, 1, 1, 1);
    }
    return color;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self
                 action:@selector(_clickSwitch:)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)_startFramesAnimation
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.015
                                                  target:self
                                                selector:@selector(_moveButtonEnterFrame:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)_stopFramesAnimation
{
    if (self.timer != nil){
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)_clickSwitch:(id)sender
{
    [self setOn:!_on animated:YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
    BOOL changed = (_on != on);
    _on = on;
    
    if (changed) {
        [self _dispatchValueChanged];
        if(animated) {
            [self _playMoveButtonAnimation];
        } else {
            self.buttonLocation = _on? 1.0: 0.0;
        }
    }
}

- (void)_dispatchValueChanged
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_playMoveButtonAnimation
{
    self.isPlayingAnimation = YES;
    self.currentFrameCount = YES;
    [self _startFramesAnimation];
}

- (void) _moveButtonEnterFrame:(NSTimer *)paramTimer
{
    if(_on)
    {
        self.buttonLocation = (CGFloat)self.currentFrameCount / (CGFloat)ButtonAnimationNeedFrames;
    }
    else
    {
        self.buttonLocation = 1.0 - (CGFloat)self.currentFrameCount / (CGFloat)ButtonAnimationNeedFrames;
    }
    self.buttonLocation *= self.buttonLocation; //let animation looks more smooth.
    
    if(self.currentFrameCount >= ButtonAnimationNeedFrames) {
        [self _stopFramesAnimation];
        self.isPlayingAnimation = NO;
    } else {
        self.currentFrameCount++;
    }
    [self setNeedsDisplay];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect drawArea = CGRectInset(rect, LineWith, LineWith);
    [self _drawBackground:drawArea withContextRef:context];
    [self _drawButton:drawArea withContextRef:context];
    
    CGContextRestoreGState(context);
}

- (void)_drawBackground:(CGRect)rect withContextRef:(CGContextRef) context
{
    CGContextSetStrokeColorWithColor(context, [UISwitch _LineColor]);
    CGContextSetFillColorWithColor(context, [self _getCurrentBackgroundColor]);
    CGContextSetLineWidth(context, LineWith);
    
    [self _drawCapsuleRect:rect withContextRef:context];
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (CGColorRef)_getCurrentBackgroundColor
{
    if (self.isPlayingAnimation) {
        return _on? [UISwitch _OffBackgroudColor]: [UISwitch _OnBackgroudColor];
    } else {
        return _on? [UISwitch _OnBackgroudColor]: [UISwitch _OffBackgroudColor];
    }
}

-(void) _drawButton:(CGRect)moveArea withContextRef:(CGContextRef)context
{
    CGFloat radius = moveArea.size.height;
    CGFloat buttonLeft = moveArea.origin.x + ( moveArea.size.width - radius )*self.buttonLocation;
    CGFloat buttonTop = moveArea.origin.y;
    
    CGContextSetStrokeColorWithColor(context, [UISwitch _LineColor]);
    CGContextSetFillColorWithColor(context, [UISwitch _ButtonColor]);
    CGContextSetLineWidth(context, LineWith);
    
    [self _drawCircleInRect:CGRectMake(buttonLeft, buttonTop, radius, radius) withContextRef:context];
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

-(void) _drawCircleInRect:(CGRect)rect withContextRef:(CGContextRef) context
{
    if(rect.size.width != rect.size.height) {
        rect.size.height = rect.size.width;
    }
    CGFloat x0 = rect.origin.x;
    CGFloat y0 = rect.origin.y;
    CGFloat x1 = rect.origin.x + rect.size.width;
    CGFloat y1 = rect.origin.y + rect.size.height;
    
    CGFloat radius = rect.size.width/2;
    
    CGContextMoveToPoint(context, x0, y0 + radius);
    CGContextAddArcToPoint(context, x0, y0, x0+radius, y0, radius);
    CGContextAddArcToPoint(context, x1, y0, x1, y0 + radius, radius);
    CGContextAddArcToPoint(context, x1, y1, x1 - radius, y1, radius);
    CGContextAddArcToPoint(context, x0, y1, x0, y1 - radius, radius);
    CGContextClosePath(context);
}

- (void) _drawCapsuleRect:(CGRect)rect withContextRef:(CGContextRef) context
{
    CGFloat x0 = rect.origin.x;
    CGFloat y0 = rect.origin.y;
    CGFloat x1 = rect.origin.x + rect.size.width;
    CGFloat y1 = rect.origin.y + rect.size.height;
    
    CGFloat radius = rect.size.height/2;
    
    CGContextMoveToPoint(context, x0, y0 + radius);
    CGContextAddArcToPoint(context, x0, y0, x0+radius, y0, radius);
    CGContextAddLineToPoint(context, x1 - radius, y0);
    CGContextAddArcToPoint(context, x1, y0, x1, y0 + radius, radius);
    CGContextAddArcToPoint(context, x1, y1, x1 - radius, y1, radius);
    CGContextAddLineToPoint(context, x0 + radius, y1);
    CGContextAddArcToPoint(context, x0, y1, x0, y1 - radius, radius);
    CGContextClosePath(context);
}

@end
