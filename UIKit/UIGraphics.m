//
//  UIGraphics.m
//  UIKit
//
//  Created by Chen Yonghui on 12/7/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGraphics.h"

#import "UIImage.h"
#import "UIScreen.h"

static NSMutableArray* contextStack()
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSMutableArray *_contextStack = threadDictionary[@"UIGraphicsContextStack"];
    if (!_contextStack) {
        _contextStack = [NSMutableArray array];
        threadDictionary[@"UIGraphicsContextStack"] = _contextStack;
    }
    return _contextStack;
}

static NSMutableArray* imageContextStack()
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSMutableArray *_contextStack = threadDictionary[@"UIGraphicsImageContextStack"];
    if (!_contextStack) {
        _contextStack = [NSMutableArray array];
        threadDictionary[@"UIGraphicsImageContextStack"] = _contextStack;
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
void     UIGraphicsBeginImageContext(CGSize size)
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
}
void     UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale)
{
    if (scale == 0.f) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    const size_t width = size.width * scale;
    const size_t height = size.height * scale;

    if (width > 0 && height > 0) {
        
        [imageContextStack() addObject:@(scale)];
        
        CGImageAlphaInfo alphaInfo = opaque? kCGImageAlphaNoneSkipFirst : kCGImageAlphaPremultipliedFirst;
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4*width, colorSpace, kCGBitmapByteOrder32Little | alphaInfo);
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
    CGFloat scale = [[imageContextStack() lastObject] floatValue];
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return image;
}

void     UIGraphicsEndImageContext(void)
{
    if ([imageContextStack() lastObject]) {
        [imageContextStack() removeLastObject];
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

