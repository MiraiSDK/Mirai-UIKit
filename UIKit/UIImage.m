//
//  UIImage.m
//  UIKit
//
//  Created by Chen Yonghui on 1/19/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIImage.h"
#import "UIGraphics.h"
#import "UIGraphics+UIPrivate.h"
#import "UIImage+UIPrivate.h"
#import "UIThreePartImage.h"
#import "UINinePartImage.h"
//#import "UIPhotosAlbum.h"
#import "UIImageRep.h"


@interface UIImage ()
@property (nonatomic, strong) CGImageRef imageRef;


@end

@implementation UIImage

@synthesize size = _size;
@synthesize scale = _scale;
@synthesize imageOrientation = _imageOrientation;

@synthesize images = _images;
@synthesize duration = _duration;

@synthesize capInsets = _capInsets;
@synthesize resizingMode = _resizingMode;

@synthesize alignmentRectInsets = _alignmentRectInsets;
@synthesize renderingMode = _renderingMode;

+ (UIImage *)_imageNamed:(NSString *)name
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [[bundle resourcePath] stringByAppendingPathComponent:name];
    UIImage *img = [self imageWithContentsOfFile:path];
    
    if (!img) {
        // if nothing is found, try again after replacing any underscores in the name with dashes.
        // I don't know why, but UIKit does something similar. it probably has a good reason and it might not be this simplistic, but
        // for now this little hack makes Ramp Champ work. :)
        path = [[[bundle resourcePath] stringByAppendingPathComponent:[[name stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"_" withString:@"-"]] stringByAppendingPathExtension:[name pathExtension]];
        img = [self imageWithContentsOfFile:path];
    }
    
    return img;
}

+ (UIImage *)imageNamed:(NSString *)name
{
    UIImage *img = [self _cachedImageForName:name];
    
    if (!img) {
        // as per the iOS docs, if it fails to find a match with the bare name, it re-tries by appending a png file extension
        img = [self _imageNamed:name] ?: [self _imageNamed:[name stringByAppendingPathExtension:@"png"]];
        [self _cacheImage:img forName:name];
    }
    
    return img;
}

+ (UIImage *)imageWithContentsOfFile:(NSString *)path
{
    return [[self alloc] initWithContentsOfFile:path];
}

+ (UIImage *)imageWithData:(NSData *)data
{
    return [[self alloc] initWithData:data];
}

+ (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale
{
    return [[self alloc] initWithData:data scale:scale];
}

+ (UIImage *)imageWithCGImage:(CGImageRef)cgImage
{
    return [[self alloc] initWithCGImage:cgImage];
}

+ (UIImage *)imageWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(UIImageOrientation)orientation
{
    return [[self alloc] initWithCGImage:cgImage scale:scale orientation:orientation];
}

#pragma mark - Initializers
- (CGImageRef)createImageNamed:(NSString *)name type:(NSString *)type
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    CGImageRef image = NULL;
    if (imagePath) {
        NSString *lowercaseType = [type lowercaseString];
        CGDataProviderRef source = CGDataProviderCreateWithFilename([imagePath UTF8String]);
        if ([lowercaseType isEqualToString:@"png"]) {
            image = CGImageCreateWithPNGDataProvider(source, NULL, NO, kCGRenderingIntentDefault);
        } else if ([lowercaseType isEqualToString:@"jpg"]) {
            image = CGImageCreateWithJPEGDataProvider(source, NULL, NO, kCGRenderingIntentDefault);
        } else {
            NSLog(@"unsupported image type:%@",type);
        }
        
    } else {
        NSLog(@"[WARNING]Can't find file: %@.%@",name,type);
    }
    return image;
}

- (id)initWithContentsOfFile:(NSString *)path
{
    return [self _initWithRepresentations:[UIImageRep imageRepsWithContentsOfFile:path]];
}

- (id)initWithData:(NSData *)data
{
    return [self _initWithRepresentations:[NSArray arrayWithObjects:[[UIImageRep alloc] initWithData:data], nil]];
}

- (id)initWithData:(NSData *)data scale:(CGFloat)scale
{
    // FIXME: needs correct scale
    return [self initWithData:data];
}

- (id)initWithCGImage:(CGImageRef)cgImage
{
    return [self initWithCGImage:cgImage scale:1 orientation:UIImageOrientationUp];
}

- (id)initWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(UIImageOrientation)orientation
{
    return [self _initWithRepresentations:[NSArray arrayWithObjects:[[UIImageRep alloc] initWithCGImage:cgImage scale:scale], nil]];
}

- (CGImageRef)CGImage
{
    return _imageRef;
}

#pragma mark - Animated images

+ (UIImage *)animatedImageNamed:(NSString *)name duration:(NSTimeInterval)duration
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    return nil;
}

+ (UIImage *)animatedResizableImageNamed:(NSString *)name capInsets:(UIEdgeInsets)capInsets duration:(NSTimeInterval)duration
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    return nil;
}

+ (UIImage *)animatedResizableImageNamed:(NSString *)name capInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode duration:(NSTimeInterval)duration
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    return nil;
}

+ (UIImage *)animatedImageWithImages:(NSArray *)images duration:(NSTimeInterval)duration
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    return nil;
}


#pragma mark - Drawing
- (void)drawAtPoint:(CGPoint)point
{
    [self drawInRect:(CGRect){point, self.size}];
}

- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    [self drawInRect:(CGRect){point, self.size} blendMode:blendMode alpha:alpha];
}

- (void)drawInRect:(CGRect)rect
{
    if (rect.size.height > 0 && rect.size.width > 0) {
        [self _drawRepresentation:[self _bestRepresentationForProposedScale:_UIGraphicsGetContextScaleFactor(UIGraphicsGetCurrentContext())] inRect:rect];
    }
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetBlendMode(ctx, blendMode);
    CGContextSetAlpha(ctx, alpha);
    
    [self drawInRect:rect];
    
    CGContextRestoreGState(ctx);
}

- (void)drawAsPatternInRect:(CGRect)rect
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets
{
    return [self resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode
{
    //FIXME: needs correct process cap insets
    return [self stretchableImageWithLeftCapWidth:capInsets.left topCapHeight:capInsets.top];
}

- (UIImage *)imageWithAlignmentRectInsets:(UIEdgeInsets)alignmentInsets
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    return self;
}

- (UIImage *)imageWithRenderingMode:(UIImageRenderingMode)renderingMode
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    return nil;
}

- (CGSize)size
{
    CGSize size = CGSizeZero;
    UIImageRep *rep = [_representations lastObject];
    const CGSize repSize = rep.imageSize;
    const CGFloat scale = rep.scale;
    size.width = repSize.width / scale;
    size.height = repSize.height / scale;
    return size;
}

- (CGFloat)scale
{
    return [self _bestRepresentationForProposedScale:2].scale;
}

#pragma mark - NSCoding
- (void) encodeWithCoder: (NSCoder*)aCoder
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
}

- (id) initWithCoder: (NSCoder*)aDecoder
{
    self = [super init];
    if (self) {
        NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    }
    return self;
}

@end

const CFStringRef kUTTypePNG = @"public.png";
const CFStringRef kUTTypeJPEG = @"public.jpeg";
const CFStringRef kUTTypeTIFF = @"public.tiff";

// return image as PNG. May return nil if image has no CGImageRef or invalid bitmap format
NSData *UIImagePNGRepresentation(UIImage *image)
{
    if (image.CGImage == NULL) {return nil;}
    
    CFMutableDataRef data = CFDataCreateMutable(NULL, 0);
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(data, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(dest, image.CGImage, NULL);
    CGImageDestinationFinalize(dest);
    return data;
}

 // return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)
NSData *UIImageJPEGRepresentation(UIImage *image, CGFloat compressionQuality)
{
    CFMutableDataRef data = CFDataCreateMutable(NULL, 0);
    CGImageDestinationRef dest = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, NULL);
    NSDictionary *properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:compressionQuality] forKey:kCGImageDestinationLossyCompressionQuality];
    CGImageDestinationAddImage(dest, image.CGImage, properties);
    CGImageDestinationFinalize(dest);
    return data;
}

@implementation UIImage (UIImageDeprecated)

- (UIImage *)stretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight
{
    const CGSize size = self.size;
    
    if ((leftCapWidth == 0 && topCapHeight == 0) || (leftCapWidth >= size.width && topCapHeight >= size.height)) {
        return self;
    } else if (leftCapWidth <= 0 || leftCapWidth >= size.width) {
        return [[UIThreePartImage alloc] initWithRepresentations:[self _representations] capSize:MIN(topCapHeight,size.height) vertical:YES];
    } else if (topCapHeight <= 0 || topCapHeight >= size.height) {
        return [[UIThreePartImage alloc] initWithRepresentations:[self _representations] capSize:MIN(leftCapWidth,size.width) vertical:NO];
    } else {
        return [[UINinePartImage alloc] initWithRepresentations:[self _representations] leftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    }
}

- (NSInteger)leftCapWidth
{
    return 0;
}

- (NSInteger)topCapHeight
{
    return 0;
}

@end
