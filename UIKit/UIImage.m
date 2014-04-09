//
//  UIImage.m
//  UIKit
//
//  Created by Chen Yonghui on 1/19/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIImage.h"
#import "UIGraphics.h"
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

+ (UIImage *)imageNamed:(NSString *)name
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    return nil;
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
    CGImageRef imageRef = NULL;
    CGDataProviderRef source = CGDataProviderCreateWithFilename([path UTF8String]);
    
    NSString *lowercasePathExtension = [[path pathExtension] lowercaseString];
    if ([lowercasePathExtension isEqualToString:@"png"]) {
        imageRef = CGImageCreateWithPNGDataProvider(source, NULL, NO, kCGRenderingIntentDefault);
    } else if ([lowercasePathExtension isEqualToString:@"jpg"]) {
        imageRef = CGImageCreateWithJPEGDataProvider(source, NULL, NO, kCGRenderingIntentDefault);
    } else {
        NSLog(@"method: %s, unsupported image type:%@",__PRETTY_FUNCTION__,lowercasePathExtension);
        return nil;
    }
    if (imageRef) {
        return [self initWithCGImage:imageRef];
    } else {
        NSLog(@"[UIImage]Create backend CGImage failed");
    }
    
    return nil;
}

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        unsigned char buffer[4];
        [data getBytes:&buffer length:4];
        
        //isJPEG?
        BOOL isJPEG = (buffer[0]==0xff &&
                       buffer[1]==0xd8 &&
                       buffer[2]==0xff);
        BOOL isPNG = NO;
        if (!isJPEG) {
            isPNG = (buffer[0]==0x89 &&
                     buffer[1]==0x50 &&
                     buffer[2]==0x4e &&
                     buffer[3]==0x47);
        }
        
        CGDataProviderRef source = CGDataProviderCreateWithCFData(data);
        CGImageRef imageRef = NULL;
        if (isJPEG) {
            imageRef = CGImageCreateWithJPEGDataProvider(source, NULL, false, kCGRenderingIntentDefault);
        } else if (isPNG) {
            imageRef = CGImageCreateWithPNGDataProvider(source, NULL, false, kCGRenderingIntentDefault);
        } else {
            NSLog(@"unknow image data, head:%02x%02x%02x%02x",buffer[0],buffer[1],buffer[2],buffer[3]);
            return nil;
        }
        
        return [self initWithCGImage:imageRef];
    }
    return self;
}

- (id)initWithData:(NSData *)data scale:(CGFloat)scale
{
    self = [super init];
    if (self) {
        NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    }
    return self;
}

- (id)initWithCGImage:(CGImageRef)cgImage
{
    return [self initWithCGImage:cgImage scale:1 orientation:UIImageOrientationUp];
}

- (id)initWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(UIImageOrientation)orientation
{
    self = [super init];
    if (self) {
        _imageRef = cgImage;
        _scale = scale;
        _imageOrientation = orientation;
    }
    return self;
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
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
}

- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
}

- (void)drawInRect:(CGRect)rect
{
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, self.CGImage);
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
}

- (void)drawAsPatternInRect:(CGRect)rect
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    return self;
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode
{
    NSLog(@"Unimplemeted method: %s",__PRETTY_FUNCTION__);
    return self;
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
    NS_UNIMPLEMENTED_LOG;
    return self;
}

- (NSInteger)leftCapWidth
{
    NS_UNIMPLEMENTED_LOG;
    return 0;
}

- (NSInteger)topCapHeight
{
    NS_UNIMPLEMENTED_LOG;
    return 0;
}

@end
