//
//  UIProgressView.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIProgressView.h"
#import "math.h"

#define DefaultFrame CGRectMake(0, 0, 200, 2)
#define FixatedTrackHeight 2
#define ProgressMoveFullWidthNeedTime 2

@interface UIProgressView()
@property (nonatomic, strong) UIView *subviewTrack;
@property (nonatomic, strong) UIView *subviewProgress;
@property CGFloat trackHeight;
@end

@implementation UIProgressView

- (instancetype)initWithProgressViewStyle:(UIProgressViewStyle)style
{
    return [self _initWithProgressViewStyle:style withFrame:DefaultFrame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self _initWithProgressViewStyle:UIProgressViewStyleDefault withFrame:frame];
}

- (instancetype)_initWithProgressViewStyle:(UIProgressViewStyle)style withFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _makeSubview];
        [self setProgressViewStyle:style];
        [self _refreshSubviewSizeAndLocation];
    }
    return self;
}

- (void)_makeSubview
{
    self.subviewTrack = [[UIView alloc] initWithFrame:
                            CGRectMake(0, 0, 0, FixatedTrackHeight)];
    self.subviewProgress = [[UIView alloc] initWithFrame:
                            CGRectMake(0, 0, self.frame.size.width, FixatedTrackHeight)];
    
    [self addSubview:self.subviewTrack];
    [self addSubview:self.subviewProgress];
}

#pragma mark - setting progress value.

- (void)setProgress:(float)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    float changedProgress = fabsf(progress - _progress);
    if (_progress != progress) {
        _progress = progress;
        if (animated) {
            [UIView animateWithDuration:[self _getProgressMoveTimeWith:changedProgress] animations:^{
                [self _refreshProgressSizeAndLocation];
            }];
        } else {
            [self _refreshProgressSizeAndLocation];
        }
    }
}

- (NSTimeInterval)_getProgressMoveTimeWith:(float)changedProgress
{
    return (NSTimeInterval)(ProgressMoveFullWidthNeedTime*changedProgress);
}

#pragma mark - appearance.

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    self.subviewProgress.backgroundColor = progressTintColor;
}

- (UIColor *)progressTintColor
{
    return self.subviewProgress.backgroundColor;
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    self.subviewTrack.backgroundColor = trackTintColor;
}

- (UIColor *)trackTintColor
{
    return self.subviewTrack.backgroundColor;
}

- (void)setProgressViewStyle:(UIProgressViewStyle)progressViewStyle
{
    switch (progressViewStyle) {
        case UIProgressViewStyleDefault:
            self.progressTintColor = [UIColor blueColor];
            self.trackTintColor = [UIColor grayColor];
            break;
            
        case UIProgressViewStyleBar:
            self.progressTintColor = [UIColor blueColor];
            self.trackTintColor = [UIColor clearColor];
            break;
    }
}

- (void)_refreshSubviewSizeAndLocation
{
    [self _refreshTrackSizeAndLocation];
    [self _refreshProgressSizeAndLocation];
}

- (void)_refreshTrackSizeAndLocation
{
    self.subviewTrack.frame = CGRectMake(0, 0, self.frame.size.width, FixatedTrackHeight);
}

- (void)_refreshProgressSizeAndLocation
{
    self.subviewProgress.frame = CGRectMake(0, 0, self.progress*self.frame.size.width, FixatedTrackHeight);
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

@end
