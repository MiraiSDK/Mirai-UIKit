//
//  UIGraphics.m
//  UIKit
//
//  Created by Chen Yonghui on 12/7/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGraphics.h"
#import "UIGraphics+UIPrivate.h"

static NSMutableArray* contextStack()
{
    static NSMutableArray *_contextStack;
    if (!_contextStack) {
        _contextStack = [NSMutableArray array];
    }
    return _contextStack;
}

CGContextRef UIGraphicsGetCurrentContext(void)
{
    return [contextStack() lastObject];
}

void UIGraphicsPushContext(CGContextRef context)
{
    [contextStack() addObject:context];
}

void UIGraphicsPopContext(void)
{
    [contextStack() removeLastObject];
}

#pragma mark -
static NSMutableArray *imageContextStatck;
void     UIGraphicsBeginImageContext(CGSize size)
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
}
void     UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale)
{
    if (scale == 0.f) {
        scale = 1;
    }
    
    const size_t width = size.width * scale;
    const size_t height = size.height * scale;

    if (width > 0 && height > 0) {
        if (!imageContextStatck) {
            imageContextStatck = [NSMutableArray array];
        }
        
        [imageContextStatck addObject:@(scale)];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4*width, colorSpace, (opaque? kCGImageAlphaNoneSkipFirst : kCGImageAlphaPremultipliedFirst));
        CGContextConcatCTM(ctx, CGAffineTransformMake(1, 0, 0, -1, 0, height));
        CGContextScaleCTM(ctx, scale, scale);
        CGColorSpaceRelease(colorSpace);
        UIGraphicsPushContext(ctx);
        CGContextRelease(ctx);
    } else {
        NSLog(@"Create image context failed, size incorrect:%.2f,%.2f",size.width,size.height);
    }

}

UIImage* UIGraphicsGetImageFromCurrentImageContext(void)
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    return cgImage;
}

CGFloat _UIGraphicsGetContextScaleFactor(CGContextRef ctx)
{
    const CGRect rect = CGContextGetClipBoundingBox(ctx);
    const CGRect deviceRect = CGContextConvertRectToDeviceSpace(ctx, rect);
    const CGFloat scale = deviceRect.size.height / rect.size.height;
    return scale;
}

void     UIGraphicsEndImageContext(void)
{
    if ([imageContextStatck lastObject]) {
        [imageContextStatck removeLastObject];
        UIGraphicsPopContext();
    }
}

void UIRectClip(CGRect rect)
{
    CGContextClipToRect(UIGraphicsGetCurrentContext(), rect);
}

void UIRectFill(CGRect rect)
{
    UIRectFillUsingBlendMode(rect, kCGBlendModeCopy);
}

void UIRectFillUsingBlendMode(CGRect rect, CGBlendMode blendMode)
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    CGContextSetBlendMode(c, blendMode);
    CGContextFillRect(c, rect);
    CGContextRestoreGState(c);
}

void UIRectFrame(CGRect rect)
{
    CGContextStrokeRect(UIGraphicsGetCurrentContext(), rect);
}

void UIRectFrameUsingBlendMode(CGRect rect, CGBlendMode blendMode)
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    CGContextSetBlendMode(c, blendMode);
    UIRectFrame(rect);
    CGContextRestoreGState(c);
}

