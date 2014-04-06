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

@interface UIPageControl ()
@property (nonatomic, strong) NSArray *dotViews;
@end

@implementation UIPageControl
@synthesize currentPage=_currentPage, numberOfPages=_numberOfPages;

- (void)setCurrentPage:(NSInteger)page
{
    if (page != _currentPage) {
        _currentPage = MIN(MAX(0,page), self.numberOfPages-1);
        [self setNeedsDisplay];
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    if (numberOfPages != _numberOfPages) {
        for (UIView *dot in self.dotViews) {
            [dot removeFromSuperview];
        }
        
        NSMutableArray *recreated = [NSMutableArray array];
        for (NSInteger i = 0; i < numberOfPages; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [self addSubview:imageView];
            [recreated addObject:imageView];
        }
        
        self.dotViews = recreated;
        
        _numberOfPages = numberOfPages;
        [self setNeedsDisplay];
    }
}

#define kDefaultDotWidth 30
#define kDefaultDotGap 5

- (void)layoutSubviews
{
    CGFloat y = CGRectGetMidY(self.bounds);
    CGFloat dotsTotalWidth = kDefaultDotWidth * self.numberOfPages + (kDefaultDotGap * (self.numberOfPages - 1));
    CGFloat xOffset = (CGRectGetWidth(self.bounds) - dotsTotalWidth) / 2.0;
    for (UIImageView *view in self.dotViews) {
        view.center = CGPointMake(xOffset, y);
        xOffset += kDefaultDotGap + kDefaultDotWidth;
    }
}
@end
