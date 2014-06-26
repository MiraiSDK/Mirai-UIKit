//
//  NSStringDrawing.m
//  UIKit
//
//  Created by Chen Yonghui on 12/8/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "NSStringDrawing.h"
#import "UIGraphics.h"
#import <CoreText/CoreText.h>
#import "UIColor.h"
#import "NSParagraphStyle.h"
#import "UIFont.h"

@implementation NSStringDrawingContext

@end

@implementation NSString(NSStringDrawing)
- (CGSize)sizeWithAttributes:(NSDictionary *)attrs
{
    NS_UNIMPLEMENTED_LOG;
    return CGSizeZero;
}

- (void)drawAtPoint:(CGPoint)point withAttributes:(NSDictionary *)attrs
{
    CGSize size = [self sizeWithAttributes:attrs];
    CGRect rect = {point,size};
    [self drawInRect:rect withAttributes:attrs];
}

- (NSDictionary *)defaultAttributes
{
    static NSDictionary *_defaultAttributes = nil;
    
    if (_defaultAttributes == nil) {
        _defaultAttributes = @{
                               NSFontAttributeName:[UIFont systemFontOfSize:12],
                               NSParagraphStyleAttributeName:[NSParagraphStyle defaultParagraphStyle],
                               NSForegroundColorAttributeName:[UIColor blackColor],
                               NSLigatureAttributeName:@1,
                               };
    }
    return _defaultAttributes;
}

- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs
{
    NSMutableDictionary *dict = [self defaultAttributes].mutableCopy;
    [dict addEntriesFromDictionary:attrs];
    
    NSAttributedString *att =[[NSAttributedString alloc] initWithString:self attributes:dict];
    
    [att drawInRect:rect];
}
@end

@implementation NSAttributedString (NSStringDrawing)

- (CGSize)size
{
    NS_UNIMPLEMENTED_LOG;
    return CGSizeZero;
}
- (void)drawAtPoint:(CGPoint)point
{
    CGRect rect = {point,self.size};
    [self drawInRect:rect];
}

- (void)drawInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CTFramesetterRef frameseter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(self));
    
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    CTFrameRef frame = CTFramesetterCreateFrame(frameseter, CFRangeMake(0, 0), path, NULL);
    
    //    CGContextSetStrokeColorWithColor(ctx, blue);
    //    CGContextSetFillColorWithColor(ctx, blue);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -rect.size.height);
    
    CTFrameDraw(frame, ctx);
    
    CGPathRelease(path);
}

@end

@implementation NSString (NSExtendedStringDrawing)

- (void)drawWithRect:(CGRect)rect options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes context:(NSStringDrawingContext *)context
{
    NS_UNIMPLEMENTED_LOG;
}

- (CGRect)boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes context:(NSStringDrawingContext *)context
{
    NS_UNIMPLEMENTED_LOG;
    return CGRectZero;
}

@end

@implementation NSAttributedString (NSExtendedStringDrawing)

- (void)drawWithRect:(CGRect)rect options:(NSStringDrawingOptions)options context:(NSStringDrawingContext *)context
{
    NS_UNIMPLEMENTED_LOG;
}

- (CGRect)boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options context:(NSStringDrawingContext *)context
{
    CGRect result = CGRectZero;

    if (options != 0) {
        NSLog(@"[WARNING]%s options unsupported.",__PRETTY_FUNCTION__);
    }
    
    if (context) {
        NSLog(@"[WARNING]%s context unsupported.",__PRETTY_FUNCTION__);
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(self));
    result.size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, size, NULL);
    
    return result;
}

@end

