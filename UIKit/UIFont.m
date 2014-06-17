//
//  UIFont.m
//  UIKit
//
//  Created by Chen Yonghui on 1/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIFont.h"
#import <CoreText/CoreText.h>

@implementation UIFont

+ (UIFont *)preferredFontForTextStyle:(NSString *)style
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (CTFontRef)_CTFont
{
    return _font;
}

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize
{
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)(fontName), fontSize, NULL);
    return [UIFont _fontWithCTFont:ctFont];
}

static NSArray *_getFontCollectionNames(CTFontCollectionRef collection, CFStringRef nameAttr)
{
    NSMutableSet *names = [NSMutableSet set];
    if (collection) {
        CFArrayRef descriptors = CTFontCollectionCreateMatchingFontDescriptors(collection);
        if (descriptors) {
            NSInteger count = CFArrayGetCount(descriptors);
            for (NSInteger i = 0; i < count; i++) {
                CTFontDescriptorRef descriptor =  (__bridge CTFontDescriptorRef)(CFArrayGetValueAtIndex(descriptors, i));
                CFTypeRef name = CTFontDescriptorCopyAttribute(descriptor, nameAttr);
                if(name) {
                    if (CFGetTypeID(name) == CFStringGetTypeID()) {
                        [names addObject:(__bridge NSString*)name];
                    }
//                    CFRelease(name);
                }
            }
//            CFRelease(descriptors);
        }
    }
    return [names allObjects];
}

+ (NSArray *)familyNames
{
    CTFontCollectionRef collection = CTFontCollectionCreateFromAvailableFonts(NULL);
    NSArray* names = _getFontCollectionNames(collection, kCTFontFamilyNameAttribute);
//    if (collection) {
//        CFRelease(collection);
//    }
    return names;
}

+ (NSArray *)fontNamesForFamilyName:(NSString *)familyName
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Robot" size:fontSize];
}

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Robot" size:fontSize];
}

+ (UIFont *)italicSystemFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Robot" size:fontSize];
}

+ (UIFont *)_fontWithCTFont:(CTFontRef)aFont
{
    UIFont *theFont = [[UIFont alloc] init];
//    theFont->_font = CFRetain(aFont);
    theFont->_font = aFont;
    return theFont;
}

- (UIFont *)fontWithSize:(CGFloat)fontSize
{
    CTFontRef newFont = CTFontCreateCopyWithAttributes(_font, fontSize, NULL, NULL);
    if (newFont) {
        UIFont *theFont = [[self class] _fontWithCTFont:newFont];
//        CFRelease(newFont);
        return theFont;
    } else {
        return nil;
    }
}

- (NSString *)fontName
{
    return (__bridge NSString *)CTFontCopyFullName(_font);
}

- (CGFloat)ascender
{
    return CTFontGetAscent(_font);
}

- (CGFloat)descender
{
    return -CTFontGetDescent(_font);
}

- (CGFloat)pointSize
{
    return CTFontGetSize(_font);
}

- (CGFloat)xHeight
{
    return CTFontGetXHeight(_font);
}

- (CGFloat)capHeight
{
    return CTFontGetCapHeight(_font);
}

- (CGFloat)lineHeight
{
    // this seems to compute heights that are very close to what I'm seeing on iOS for fonts at
    // the same point sizes. however there's still subtle differences between fonts on the two
    // platforms (iOS and Mac) and I don't know if it's ever going to be possible to make things
    // return exactly the same values in all cases.
    return ceilf(self.ascender) - floorf(self.descender) + ceilf(CTFontGetLeading(_font));
}

- (NSString *)familyName
{
    return (__bridge NSString *)CTFontCopyFamilyName(_font);
}

+ (UIFont *)fontWithDescriptor:(UIFontDescriptor *)descriptor size:(CGFloat)pointSize
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (UIFontDescriptor *)fontDescriptor
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}
@end
