//
//  UILable.m
//  UIKit
//
//  Created by Chen Yonghui on 12/8/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UILabel.h"
#import <UIKit/UIGraphics.h>
#import "NSStringDrawing.h"
#import "UIColor.h"
#import "UIFont.h"

#import <CoreText/CoreText.h>
#import "UIKit+Android.h"
#import "UIInterface.h"

@implementation UILabel
{
    NSString *_drawText;
}
@synthesize font = _font;
@synthesize textColor = _textColor;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = NO;
        self.textAlignment = UITextAlignmentLeft;
        self.lineBreakMode = UILineBreakModeTailTruncation;
        self.textColor = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.enabled = YES;
        self.font = nil;
        self.numberOfLines = 1;
        self.contentMode = UIViewContentModeLeft;
        self.clipsToBounds = YES;
        self.shadowOffset = CGSizeMake(0,-1);
        self.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    }
    return self;
}

- (void)setText:(NSString *)newText
{
    if (_text != newText) {
        _text = [newText copy];
        _drawText = _text;
        [self setNeedsDisplay];
    }
}

- (void)setFont:(UIFont *)newFont
{
//    assert(newFont != nil);
    
    if (newFont != _font) {
        _font = newFont;
        [self setNeedsDisplay];
    }
}

- (UIFont *)font
{
    if (_font == nil) {
        return [UIFont systemFontOfSize:17];
    }
    return _font;
}

- (void)setTextColor:(UIColor *)newColor
{
    if (newColor != _textColor) {
        _textColor = newColor;
        [self setNeedsDisplay];
    }
}

- (UIColor *)textColor
{
    if (_textColor == nil) {
        return [UIColor darkTextColor];
    }
    return _textColor;
}

- (void)setShadowColor:(UIColor *)newColor
{
    if (newColor != _shadowColor) {
        _shadowColor = newColor;
        [self setNeedsDisplay];
    }
}

- (void)setShadowOffset:(CGSize)newOffset
{
    if (!CGSizeEqualToSize(newOffset,_shadowOffset)) {
        _shadowOffset = newOffset;
        [self setNeedsDisplay];
    }
}

- (void)setTextAlignment:(NSTextAlignment)newAlignment
{
    if (newAlignment != _textAlignment) {
        _textAlignment = newAlignment;
        [self setNeedsDisplay];
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)newMode
{
    if (newMode != _lineBreakMode) {
        _lineBreakMode = newMode;
        [self setNeedsDisplay];
    }
}

- (void)setEnabled:(BOOL)newEnabled
{
    if (newEnabled != _enabled) {
        _enabled = newEnabled;
        [self setNeedsDisplay];
    }
}

- (void)setNumberOfLines:(NSInteger)lines
{
    if (lines != _numberOfLines) {
        _numberOfLines = lines;
        [self setNeedsDisplay];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    if ([_text length] > 0) {
        CGSize maxSize = bounds.size;
        if (numberOfLines > 0) {
            maxSize.height = _font.lineHeight * numberOfLines;
        }
        CGSize size = [_text sizeWithFont: _font constrainedToSize: maxSize lineBreakMode: _lineBreakMode];
        return (CGRect){bounds.origin, size};
    }
    return (CGRect){bounds.origin, {0, 0}};
}

- (NSDictionary *)_attributes
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    if (self.font) {
        attributes[NSFontAttributeName] = self.font;
    } else {
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    }
    
    if (self.textColor) {
        attributes[NSForegroundColorAttributeName] = self.textColor;
    }
    
    if (self.shadowColor) {
        NSLog(@"[UILabel] shadowColor unimplemented");
    }

    // TODO: alignment, linebreakMode
    CTTextAlignment textAlign = NSTextAlignmentToCTTextAlignment(self.textAlignment);
    CTLineBreakMode lineBreakMode = (CTLineBreakMode)self.lineBreakMode;
    
    CTParagraphStyleSetting settings[] = {
        { kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment), &textAlign },
        { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},  
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);
    attributes[(NSString *)kCTParagraphStyleAttributeName] = (__bridge id)(paragraphStyle);
    CFRelease(paragraphStyle);

    return attributes;
}

- (void)drawTextInRect:(CGRect)rect
{
    [_drawText drawInRect:rect withAttributes:[self _attributes]];
}

- (void)drawRect:(CGRect)rect
{
    CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
    
    if ([_text length] > 0) {
        CGContextSaveGState(UIGraphicsGetCurrentContext());
        if (self.backgroundColor) {
            [self.backgroundColor setFill];
            CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
        }
        
        const CGRect bounds = self.bounds;
        CGRect drawRect = CGRectZero;
        
        // find out the actual size of the text given the size of our bounds
        CGSize maxSize = bounds.size;
        if (_numberOfLines > 0) {
            maxSize.height = self.font.lineHeight * _numberOfLines;
        }
        if (maxSize.height > bounds.size.height) {
            maxSize.height = bounds.size.height;
        }
        
        _drawText = _text;
        NSDictionary *attributes = [self _attributes];
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:_drawText
                                                                 attributes:attributes];
        CGRect boundingRect = [as boundingRectWithSize:maxSize options:0 context:nil];
        
        if (![self _isSize:maxSize containSize:boundingRect.size]) {
            boundingRect = [self _clipBoundingRectToWithMaxSize:maxSize attributes:attributes boundingRect:boundingRect];
            as = [[NSAttributedString alloc] initWithString:_drawText attributes:attributes];
        }
        
        drawRect.size = boundingRect.size;
        
        //
        // FIXME: Workaround text out of bounds bug,
        // to support truncating, we needs manual create CTFrame,
        // get CTLines, and create truncated version using CTLineCreateTruncatedLine
        if (drawRect.size.height > bounds.size.height) {
            drawRect.size.height = bounds.size.height;
        }
        
        // now vertically center it
        drawRect.origin.y = roundf((bounds.size.height - drawRect.size.height) / 2.f);
        
        // now position it correctly for the width
        // this might be cheating somehow and not how the real thing does it...
        // I didn't spend a ton of time investigating the sizes that it sends the drawTextInRect: method
        drawRect.origin.x = 0;
        drawRect.size.width = bounds.size.width;
        
        // if there's a shadow, let's set that up
        CGSize offset = _shadowOffset;
        
        // stupid version compatibilities..
//        if (floorf(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_6) {
//            offset.height *= -1;
//        }
        
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), offset, 0, _shadowColor.CGColor);
        
        // finally, draw the real label
        UIColor *drawColor = (_highlighted && _highlightedTextColor)? _highlightedTextColor : [self textColor];
        [drawColor setFill];
        [self drawTextInRect:drawRect];
        
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
    }
}

- (BOOL)_isSize:(CGSize)containerSize containSize:(CGSize)size
{
    return containerSize.width >= size.width && containerSize.height >= size.height;
}


- (CGRect)_clipBoundingRectToWithMaxSize:(CGSize)maxSize attributes:(NSDictionary *)attributes
                             boundingRect:(CGRect)boundingRect
{
    NSUInteger subTextToIndex = 0;
    CGRect lastBoundingRect = CGRectNull;
    NSString *lastMatchText = nil;
    
    CGRect testBoudingRect = CGRectNull;
    NSString *testDrawText = nil;
    
    do {
        lastMatchText = testDrawText;
        lastBoundingRect = testBoudingRect;
        
        testDrawText = [[_text substringToIndex:subTextToIndex] stringByAppendingString:@"..."];
        NSAttributedString *testAs = [[NSAttributedString alloc] initWithString:testDrawText attributes:attributes];
        testBoudingRect = [testAs boundingRectWithSize:maxSize options:0 context:nil];
        subTextToIndex++;
    } while ([self _isSize:maxSize containSize:testBoudingRect.size] && subTextToIndex <= _text.length - 1);
    
    if (!lastMatchText) {
        lastMatchText = _text;
        lastBoundingRect = boundingRect;
    }
    _drawText = lastMatchText;
    
    return boundingRect;
}

- (void)setFrame:(CGRect)newFrame
{
    const BOOL redisplay = !CGSizeEqualToSize(newFrame.size,self.frame.size);
    [super setFrame:newFrame];
    if (redisplay) {
        [self setNeedsDisplay];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size = CGSizeMake(((_numberOfLines > 0)? CGFLOAT_MAX : size.width), ((_numberOfLines <= 0)? CGFLOAT_MAX : (_font.lineHeight*_numberOfLines)));
    return [_text sizeWithFont:[self font] constrainedToSize:size lineBreakMode:_lineBreakMode];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted != _highlighted) {
        _highlighted = highlighted;
        [self setNeedsDisplay];
    }
}

@end
