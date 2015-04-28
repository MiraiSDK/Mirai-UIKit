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

#import "UIPageControl.h"
#import "UIImageView.h"
#import "TNImageBuffer.h"
#import "UIGraphics.h"

#import <QuartzCore/QuartzCore.h>

@interface UIPageControl ()
@property (nonatomic, strong) NSArray *dotViews;
@end

@implementation UIPageControl
@synthesize currentPage=_currentPage, numberOfPages=_numberOfPages;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _settingPropertiesDefaultValue];
        self.numberOfPages = 1;
    }
    return self;
}

- (void)_settingPropertiesDefaultValue
{
    _pageIndicatorTintColor = [UIColor grayColor];
    _currentPageIndicatorTintColor = [UIColor whiteColor];
    _dotViews = @[];
}

- (void)setCurrentPage:(NSInteger)page
{
    if (page != _currentPage) {
        _currentPage = MIN(MAX(0,page), self.numberOfPages-1);
        [self _refreshDotsAppearance];
    }
}

#define kDefaultDotWidth 30
#define kDefaultDotGap 5

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    if (numberOfPages != _numberOfPages) {
        for (UIView *dot in self.dotViews) {
            [dot removeFromSuperview];
        }
        
        NSMutableArray *recreated = [NSMutableArray array];
        for (NSInteger i = 0; i < numberOfPages; i++) {
            CGRect imageViewFrame = CGRectMake(0, 0, kDefaultDotWidth, kDefaultDotWidth);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
            [self addSubview:imageView];
            [recreated addObject:imageView];
        }
        
        self.dotViews = recreated;
        
        _numberOfPages = numberOfPages;
        [self setNeedsDisplay];
    }
}

- (void)layoutSubviews
{
    [self _refreshDotsLocation];
    [self _refreshDotsAppearance];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor
{
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self _refreshDotsAppearance];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
{
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self _refreshDotsAppearance];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage
{
    _hidesForSinglePage = hidesForSinglePage;
    [self _refreshDotsAppearance];
}

- (void)_refreshDotsLocation
{
    CGFloat y = CGRectGetMidY(self.bounds);
    CGFloat dotsTotalWidth = kDefaultDotWidth * self.numberOfPages + (kDefaultDotGap * (self.numberOfPages - 1));
    CGFloat xOffset = (CGRectGetWidth(self.bounds) - dotsTotalWidth) / 2.0;
    for (UIImageView *view in self.dotViews) {
        view.frame = CGRectMake(xOffset + kDefaultDotWidth/2, y + kDefaultDotWidth/2,
                                view.bounds.size.width, view.bounds.size.height);
        xOffset += kDefaultDotGap + kDefaultDotWidth;
    }
}

- (void)_refreshDotsAppearance
{
    if (self.hidesForSinglePage && self.numberOfPages == 1) {
        [self _setDotsHidden:YES];
        return;
    }
    [self _setDotsHidden:NO];
    [self _refreshDotsColor];
}

- (void)_setDotsHidden:(BOOL)hidden
{
    for (UIImageView *view in self.dotViews) {
        view.hidden = hidden;
    }
}

- (void)_refreshDotsColor
{
    for (NSUInteger i = 0; i < self.dotViews.count; i ++) {
        UIImageView *view = [self.dotViews objectAtIndex:i];
        if (i == self.currentPage) {
            view.image = [self _drawCircleImageWithColor:self.currentPageIndicatorTintColor];
        } else {
            view.image = [self _drawCircleImageWithColor:self.pageIndicatorTintColor];
        }
    }
}

- (UIImage *)_drawCircleImageWithColor:(UIColor *)color
{
    NSString *key = [self _hexFromUIColor:color];
    return [TNImageBuffer drawImageAndBufferedItWithClass:UIPageControl.class withKey:key
                                           withDrawAction:^UIImage *{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(kDefaultDotWidth, kDefaultDotWidth), YES, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        [self _drawImageIntoImageContext:context withColor:color];
        CGContextRestoreGState(context);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }];
}

- (NSString *)_hexFromUIColor:(UIColor *)color
{
    if (color == nil) {
        return @"#FFFFFF";
    }
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[30] green:components[141] blue:components[13] alpha:components[1]];
    }
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return @"#FFFFFF";
    }
    int red = (int)((CGColorGetComponents(color.CGColor))[0]*255.0);
    int green = (int)((CGColorGetComponents(color.CGColor))[1]*255.0);
    int blue = (int)((CGColorGetComponents(color.CGColor))[2]*255.0);
    return [NSString stringWithFormat:@"#%02X%02X%02X", red, green, blue];
}

- (void)_drawImageIntoImageContext:(CGContextRef)context withColor:(UIColor *)color
{
    // I can't draw any ellipse, I so replace it with a rectangle.
    
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextAddEllipseInRect(context, CGRectMake(0, 0, kDefaultDotWidth, kDefaultDotWidth));
//    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, kDefaultDotWidth, kDefaultDotWidth));
}

@end
