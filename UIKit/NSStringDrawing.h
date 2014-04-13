//
//  NSStringDrawing.h
//  UIKit
//
//  Created by Chen Yonghui on 12/8/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/NSAttributedString.h>
#import <UIKit/UIKitDefines.h>


@interface NSStringDrawingContext : NSObject
@property(nonatomic) CGFloat minimumScaleFactor;
@property(nonatomic, readonly) CGFloat actualScaleFactor;
@property(nonatomic, readonly) CGRect totalBounds;

//@property(nonatomic) CGFloat minimumTrackingAdjustment NS_DEPRECATED_IOS(6_0,7_0);
//@property(nonatomic, readonly) CGFloat actualTrackingAdjustment NS_DEPRECATED_IOS(6_0,7_0);
@end

@interface NSString(NSStringDrawing)
- (CGSize)sizeWithAttributes:(NSDictionary *)attrs;
- (void)drawAtPoint:(CGPoint)point withAttributes:(NSDictionary *)attrs;
- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs;
@end

@interface NSAttributedString(NSStringDrawing)
- (CGSize)size;
- (void)drawAtPoint:(CGPoint)point;
- (void)drawInRect:(CGRect)rect;
@end

typedef NS_ENUM(NSInteger, NSStringDrawingOptions) {
    NSStringDrawingTruncatesLastVisibleLine = 1 << 5,    NSStringDrawingUsesLineFragmentOrigin = 1 << 0,
    NSStringDrawingUsesFontLeading = 1 << 1,
    NSStringDrawingUsesDeviceMetrics = 1 << 3,
};


@interface NSString (NSExtendedStringDrawing)
- (void)drawWithRect:(CGRect)rect options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes context:(NSStringDrawingContext *)context;
- (CGRect)boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes context:(NSStringDrawingContext *)context;
@end

@interface NSAttributedString (NSExtendedStringDrawing)
- (void)drawWithRect:(CGRect)rect options:(NSStringDrawingOptions)options context:(NSStringDrawingContext *)context;
- (CGRect)boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options context:(NSStringDrawingContext *)context;
@end


