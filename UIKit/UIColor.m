//
//  UIColor.m
//  UIKit
//
//  Created by Chen Yonghui on 1/19/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIColor.h"
#import <dispatch/dispatch.h>
#import <CoreGraphics/CoreGraphics.h>
#import "UIGraphics.h"

@interface UIColor ()
@property (nonatomic, strong) CGColorRef color;
@end

@implementation UIColor

#pragma mark - Convenience methods
+ (UIColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
    return [[self alloc] initWithWhite:white alpha:alpha];
}

+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    return [[self alloc] initWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[self alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithCGColor:(CGColorRef)cgColor
{
    return [[self alloc] initWithCGColor:cgColor];
}

+ (UIColor *)colorWithPatternImage:(UIImage *)image
{
    
    return [[self alloc] initWithPatternImage:image];
}

#pragma mark - Initializers
- (UIColor *)initWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
    self = [super init];
    if (self) {
        _color = CGColorCreateGenericGray(white, alpha);
    }
    return self;
}

static CGFloat HueToRgb(float p, float q, float t)
{
    if (t < 0.0f) t += 1.0f;
    if (t > 1.0f) t -= 1.0f;
    if (t < 1.0f / 6.0f) return p + (q - p) * 6.0f * t;
    if (t < 1.0f / 2.0f) return q;
    if (t < 2.0f / 3.0f) return p + (q - p) * (2.0f / 3.0f - t) * 6.0f;
    return p;
}

static void rgbaFromHSL(CGFloat hue, CGFloat saturation, CGFloat brightness, CGFloat alpha,
                        CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *outAlpha)
{
    CGFloat r, g, b;
    
    if (saturation == 0.0f) {
        r = g = b = brightness;
    } else {
        CGFloat q = brightness< 0.5f ? brightness * (1.0f + saturation) : brightness + saturation - brightness * saturation;
        CGFloat p = 2.0f * brightness - q;
        r = HueToRgb(p, q, hue + 1.0f / 3.0f);
        g = HueToRgb(p, q, hue);
        b = HueToRgb(p, q, hue - 1.0f / 3.0f);
    }
    
    *red = r;
    *green = g;
    *blue = b;
    *outAlpha = alpha;
}

void HSVtoRGB(float h, float s, float v,
              float *r, float *g, float *b)
{
    int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
    i %= 6;             //
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

- (UIColor *)initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    CGFloat red,green,blue;
    CGFloat h = hue * 360.0f;
    
    HSVtoRGB(h, saturation, brightness, &red, &green, &blue);
    return [self initWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    self = [super init];
    if (self) {
        _color = CGColorCreateGenericRGB(red, green, blue, alpha);
    }
    return self;
}

- (UIColor *)initWithCGColor:(CGColorRef)cgColor
{
    self = [super init];
    if (self) {
        _color = cgColor;
    }
    return self;
}

- (UIColor *)initWithPatternImage:(UIImage*)image
{
    self = [super init];
    if (self) {
        NSLog(@"unimplemented methods %s",__PRETTY_FUNCTION__);
        _color = CGColorCreateGenericGray(0, 1);
    }
    return self;
}
//- (UIColor *)initWithCIColor:(CIColor *)ciColor NS_AVAILABLE_IOS(5_0);


+ (UIColor *)blackColor
{
    static UIColor *_black = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _black = [UIColor colorWithWhite:0 alpha:1];
    });
    return _black;
}

+ (UIColor *)darkGrayColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithWhite:0.333 alpha:1];
    });
    return _value;
}

+ (UIColor *)lightGrayColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithWhite:0.667 alpha:1];
    });
    return _value;
}

+ (UIColor *)whiteColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithWhite:1.0 alpha:1];
    });
    return _value;
}

+ (UIColor *)grayColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithWhite:0.5 alpha:1];
    });
    return _value;
}

+ (UIColor *)redColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    });
    return _value;
}

+ (UIColor *)greenColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    });
    return _value;
}

+ (UIColor *)blueColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    });
    return _value;
}

+ (UIColor *)cyanColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0];
    });
    return _value;
}

+ (UIColor *)yellowColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    });
    return _value;
}

+ (UIColor *)magentaColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0];
    });
    return _value;
}

+ (UIColor *)orangeColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
    });
    return _value;
}

+ (UIColor *)purpleColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithRed:0.5 green:0.0 blue:0.5 alpha:1.0];
    });
    return _value;
}

+ (UIColor *)brownColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithRed:0.6 green:0.4 blue:0.2 alpha:1.0];
    });
    return _value;
}

+ (UIColor *)clearColor
{
    static UIColor *_value = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [UIColor colorWithWhite:0.0 alpha:0.0];
    });
    return _value;
}


- (void)set
{
    [self setFill];
    [self setStroke];
}

- (void)setFill
{
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _color);
}

- (void)setStroke
{
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), _color);
}

- (BOOL)getWhite:(CGFloat *)white alpha:(CGFloat *)alpha
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha
{
    NS_UNIMPLEMENTED_LOG;
    return NO;
}

//FIXME: should consider convert color space
- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
    size_t numberOfComponents = CGColorGetNumberOfComponents(_color);
    const CGFloat *components = CGColorGetComponents(_color);
    if (numberOfComponents == 4) {
        //assume it's rgba
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = components[3];
        return YES;
    } else if (numberOfComponents == 3) {
        *red = components[0];
        *green = components[1];
        *blue = components[2];
        *alpha = 1;
        return YES;
    } else if (numberOfComponents == 2) {
        // gray whith alpha
        *red = components[0];
        *green = components[0];
        *blue = components[0];
        *alpha = components[1];
    } else if (numberOfComponents == 1) {
        *red = components[0];
        *green = components[0];
        *blue = components[0];
        *alpha = 1;
    }
    
    return NO;
}

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha
{
    CGColorRef clr = CGColorCreateCopyWithAlpha(_color, alpha);
    return [UIColor colorWithCGColor:clr];
}

- (CGColorRef)CGColor
{
    return _color;
}

- (id)copyWithZone: (NSZone*)zone
{
    UIColor *copy = [UIColor colorWithCGColor:_color];
    return copy;
}
@end
