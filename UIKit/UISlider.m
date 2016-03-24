//
//  UISlider.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UISlider.h"
#import "UIControl.h"
#import "UIView.h"
#import "UIImageView.h"
#import "UIEvent.h"
#import "UITouch.h"
#import "UIImage.h"
#import "UIGraphics.h"
#import "UIPanGestureRecognizer.h"
#import "math.h"

#define TintState 0xFFFFFFFF

#define DefaultSubviewIsOpaque NO
#define DefaultLineWith 2.0
#define DefaultStrokeColor CGColorCreateGenericRGB(0.5, 0.5, 0.5, 1.0)

#define DefaultThumbColor [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
#define DefaultMinimumTrackColor [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0]
#define DefaultMaximumTrackColor [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]

#define DefaultThumbImageSize CGSizeMake(42, 42)
#define DefaultThumbContainerMinimumSize CGSizeMake(42, 42)
#define DefaultMinimumTrackSize CGSizeMake(5, 5)
#define DefaultMaximumTrackSize CGSizeMake(5, 5)

@interface UISlider()
@property CGPoint firstThumbTouchDownLocation;
@property BOOL hasDragThumbLastTouch;
@property BOOL wasContinuousBeforeDrag;
@property float valueBeforeBeginDrag;
@property (nonatomic, assign) id privateDelegate;
@property (nonatomic, strong) UIControl *subviewThumbContainer;
@property (nonatomic, strong) UIImageView *subviewThumbImage;
@property (nonatomic, strong) UIImageView *subviewMinimumTrackImage;
@property (nonatomic, strong) UIImageView *subviewMaximumTrackImage;
@property (nonatomic, strong) NSMutableDictionary *thumbImageDictionary;
@property (nonatomic, strong) NSMutableDictionary *minimumTrackImageDictionary;
@property (nonatomic, strong) NSMutableDictionary *maximumTrackImageDictionary;
@end

@implementation UISlider

+ (void) initialize
{
    [UISlider _initializeDefaultImages];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setDefaultValues];
        [self _makeSubviewImage];
        [self _makeSubviewDictionary];
        [self _setDefaultView];
        [self _registerDraggingThumbGestureRecognizer];
        [self _setDefaultContinousValue];
    }
    return self;
}

#pragma mark - setter and getter of value.

- (void)_setDefaultValues
{
    _value = 0.0;
    _minimumValue = 0.0;
    _maximumValue = 1.0;
}

- (void)setValue:(float)value
{
    [self setValue:value animated:NO];
}

- (void)setValue:(float)value animated:(BOOL)animated;
{
    float oldValue = _value;
    [self _setValueButNotTriggerValueChanged:value animated:animated];
    if (_value != oldValue) {
        [self _triggerValueChangedEvent];
    }
}

- (void)setMinimumValue:(float)minimumValue
{
    _minimumValue = minimumValue;
    _maximumValue = fmaxf(minimumValue, _maximumValue);
    [self _resetValueToClampValueIfNeed];
}

- (void)setMaximumValue:(float)maximumValue
{
    _maximumValue = maximumValue;
    _minimumValue = fminf(maximumValue, _minimumValue);
    [self _resetValueToClampValueIfNeed];
}

- (void)_setValueButNotTriggerValueChanged:(float)value animated:(BOOL)animated
{
    value = [self _clampValueBetweenMinimumAndMaximum:value];
    if (value != _value) {
        [self _setValueAndResetThumbLocationIfPercentOfValueChanged:value];
    }
}

- (void)_setValueAndResetThumbLocationIfPercentOfValueChanged:(float)value
{
    float oldPercentOfValueLocation = [self _getPercentOfValueLocation];
    _value = value;
    
    if (oldPercentOfValueLocation != [self _getPercentOfValueLocation]) {
        [self _resetSubviewSizeAndLocation];
    }
}

- (void)_resetValueToClampValueIfNeed
{
    self.value = _value;
}

- (float)_clampValueBetweenMinimumAndMaximum:(float)value
{
    value = fmaxf(_minimumValue, value);
    value = fminf(_maximumValue, value);
    return value;
}

- (float)_getPercentOfValueLocation
{
    float location = self.value - self.minimumValue;
    float distance = self.maximumValue - self.minimumValue;
    
    if (distance == 0) {
        return 0;
    } else {
        return location/distance;
    }
}

#pragma mark - dragging thumb, managememt and animation.

- (void)_registerDraggingThumbGestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onDrag:)];
    [self.subviewThumbContainer addGestureRecognizer:panGestureRecognizer];
}

- (void)_onDrag:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint location = [panGestureRecognizer translationInView:self];
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self _dragWhenBeginWithTouchLocation:location];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self _dragWhenChangedWithTouchLocation:location];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self _dragWhenEndedWithTouchLocation:location];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            //TODO resume the thumb to the location before dragged.
            break;
            
        default:
            break;
    }
}

- (void)_dragWhenBeginWithTouchLocation:(CGPoint)location
{
    self.hasDragThumbLastTouch = NO;
    self.wasContinuousBeforeDrag = self.continuous;
    self.valueBeforeBeginDrag = self.value;
    self.firstThumbTouchDownLocation = location;
    
    if ([self.privateDelegate respondsToSelector:@selector(onStartDragging)]) {
        [self.privateDelegate performSelector:@selector(onStartDragging)];
    }
}

- (void)_dragWhenChangedWithTouchLocation:(CGPoint)location
{
    float value = [self _getValueOfCurrentDragWithLocation:location];
    [self _setValueButNotTriggerValueChanged:value animated:NO];
    self.hasDragThumbLastTouch = YES;
    
    if (self.wasContinuousBeforeDrag) {
        [self _triggerValueChangedEvent];
    }
}

- (void)_dragWhenEndedWithTouchLocation:(CGPoint)location
{
    if (self.hasDragThumbLastTouch) {
        float value = [self _getValueOfCurrentDragWithLocation:location];
        [self _setValueButNotTriggerValueChanged:value animated:NO];
        if (value != self.valueBeforeBeginDrag) {
            [self _triggerValueChangedEvent];
        }
    }
    if ([self.privateDelegate respondsToSelector:@selector(onEndDragging)]) {
        [self.privateDelegate performSelector:@selector(onEndDragging)];
    }
}

- (void)_setDefaultContinousValue
{
    self.continuous = YES;
}

- (float)_getValueOfCurrentDragTouch:(UITouch *)touch
{
    return [self _getValueOfCurrentDragWithLocation:[touch locationInView:self]];
}

- (float)_getValueOfCurrentDragWithLocation:(CGPoint)location
{
    float valueRange = self.maximumValue - self.minimumValue;
    float changedLocation = location.x - self.firstThumbTouchDownLocation.x;
    
    return self.valueBeforeBeginDrag + changedLocation*valueRange/[self _getTrackTotalWidth];
}

- (void)_triggerValueChangedEvent
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_handleAllTouchEventsIfEnableWithEvent:(UIEvent *)event handle:(void (^)(UITouch *))handler
{
    if (self.enabled) {
        for (id touch in [event allTouches]) {
            handler((UITouch *)touch);
        }
    }
}

- (CGPoint)_getTouchLocationOfEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    return [touch locationInView:self];
}

#pragma mark - subview size and location.

- (void)_resetSubviewSizeAndLocation
{
    CGRect thumbContainerFrame = self.subviewThumbContainer.frame;
    CGRect thumbImageFrame = self.subviewThumbImage.frame;
    CGFloat gapSpace = (thumbContainerFrame.size.width - thumbImageFrame.size.width)/2;
    CGFloat thumbImageX = [self _getThumbImageXLocation];
    CGFloat thumbImageRight = thumbImageX + self.subviewThumbImage.frame.size.width;
    
    [self _letYLocationAlignCenter:self.subviewThumbContainer
                   andSetXLocation:thumbImageX - gapSpace];
    [self _letYLocationAlignCenter:self.subviewMinimumTrackImage
                   andSetXLocation:0];
    [self _letYLocationAlignCenter:self.subviewMaximumTrackImage
                   andSetXLocation:thumbImageRight];
    
    CGFloat minimumWidth = thumbImageX;
    CGFloat maximumWidth = fmax(0, self.frame.size.width - thumbImageRight);
    
    [self _setWidth:minimumWidth forSubview:self.subviewMinimumTrackImage];
    [self _setWidth:maximumWidth forSubview:self.subviewMaximumTrackImage];
}

- (CGFloat)_getThumbImageXLocation
{
    CGFloat space = fmaxf(0, [self _getTrackCanMoveWidth]);
    return space*[self _getPercentOfValueLocation];
}

- (void)_letYLocationAlignCenter:(UIView *)subview andSetXLocation:(CGFloat)xLocation
{
    CGRect subviewFrame = subview.frame;
    CGFloat space = (self.frame.size.height - subviewFrame.size.height)/2;
    subview.frame = CGRectMake(xLocation, space,
                               subviewFrame.size.width, subviewFrame.size.height);
}

- (void)_setWidth:(CGFloat)width forSubview:(UIImageView *)subview
{
    CGRect frame = subview.frame;
    subview.frame = CGRectMake(frame.origin.x, frame.origin.y,
                               width, frame.size.height);
}

#pragma mark - set and get appearance.

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state
{
    self.thumbTintColor = nil;
    [self _setSubviewImage:image toDictionary:self.thumbImageDictionary forState:state];
}

- (void)setMinimumTrackImage:(UIImage *)image forState:(UIControlState)state
{
    self.minimumTrackTintColor = nil;
    [self _setSubviewImage:image toDictionary:self.minimumTrackImageDictionary forState:state];
}

- (void)setMaximumTrackImage:(UIImage *)image forState:(UIControlState)state
{
    self.maximumTrackTintColor = nil;
    [self _setSubviewImage:image toDictionary:self.maximumTrackImageDictionary forState:state];
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor
{
    _thumbTintColor = thumbTintColor;
    [self setSubivewTintColorImage:[self.class _getDefaultThumbWithTintColor:thumbTintColor]
                      toDictionary:self.thumbImageDictionary];
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor
{
    _minimumTrackTintColor = minimumTrackTintColor;
    [self setSubivewTintColorImage:[self.class _getDefaultMinimumTrackWithTintColor:minimumTrackTintColor]
                      toDictionary:self.minimumTrackImageDictionary];
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor
{
    _maximumTrackTintColor = maximumTrackTintColor;
    [self setSubivewTintColorImage:[self.class _getDefaultMaximumTrackWithTintColor:maximumTrackTintColor]
                      toDictionary:self.maximumTrackImageDictionary];
}

- (UIImage *)thumbImageForState:(UIControlState)state
{
    if (state == TintState) {
        return nil;
    }
    return [self.thumbImageDictionary objectForKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (UIImage *)minimumTrackImageForState:(UIControlState)state
{
    if (state == TintState) {
        return nil;
    }
    return [self.minimumTrackImageDictionary objectForKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (UIImage *)maximumTrackImageForState:(UIControlState)state
{
    if (state == TintState) {
        return nil;
    }
    return [self.maximumTrackImageDictionary objectForKey:[NSNumber numberWithUnsignedInteger:state]];
}

- (void)_makeSubviewImage
{
    self.subviewMinimumTrackImage = [[UIImageView alloc] init];
    self.subviewMaximumTrackImage = [[UIImageView alloc] init];
    [self addSubview:self.subviewMinimumTrackImage];
    [self addSubview:self.subviewMaximumTrackImage];
    
    self.subviewThumbImage = [[UIImageView alloc] init];
    self.subviewThumbContainer = [[UIControl alloc] init];
    [self.subviewThumbContainer addSubview:self.subviewThumbImage];
    [self addSubview:self.subviewThumbContainer];
}

- (void)_makeSubviewDictionary
{
    self.thumbImageDictionary = [[NSMutableDictionary alloc] init];
    self.minimumTrackImageDictionary = [[NSMutableDictionary alloc] init];
    self.maximumTrackImageDictionary = [[NSMutableDictionary alloc] init];
}

- (void)_setDefaultView
{
    self.thumbTintColor = DefaultThumbColor;
    self.minimumTrackTintColor = DefaultMinimumTrackColor;
    self.maximumTrackTintColor = DefaultMaximumTrackColor;
}

- (void)_setSubviewImage:(UIImage *)image toDictionary:(NSMutableDictionary *)dictionary forState:(UIControlState)state
{
    [dictionary removeObjectForKey:[NSNumber numberWithUnsignedInteger:TintState]];
    [dictionary setObject:image forKey:[NSNumber numberWithUnsignedInteger:state]];
    [self _refreshCurrentSubview];
}

- (void)setSubivewTintColorImage:(UIImage *)image toDictionary:(NSMutableDictionary *)dictionary
{
    [dictionary removeAllObjects];
    [dictionary setObject:image forKey:[NSNumber numberWithUnsignedInteger:TintState]];
    [self _refreshCurrentSubview];
}

- (void)_refreshCurrentSubview
{
    UIImage *thumb = [self _getImageWithCurrentStateFromDictionary:self.thumbImageDictionary];
    UIImage *minimumTrack = [self _getImageWithCurrentStateFromDictionary:self.minimumTrackImageDictionary];
    UIImage *maximumTrack = [self _getImageWithCurrentStateFromDictionary:self.maximumTrackImageDictionary];
    
    [self _setImage:thumb forSubview:self.subviewThumbImage];
    [self _setImage:minimumTrack forSubview:self.subviewMinimumTrackImage];
    [self _setImage:maximumTrack forSubview:self.subviewMaximumTrackImage];
    
    [self _resetThumbContainerSizeByImage:thumb];
    [self _resetSubviewSizeAndLocation];
}

- (void)_resetThumbContainerSizeByImage:(UIImage *)thumbImage
{
    CGSize minimumSize = DefaultThumbContainerMinimumSize;
    CGSize size = CGSizeMake(MAX(minimumSize.width, thumbImage.size.width),
                             MAX(minimumSize.height, thumbImage.size.height));
    CGPoint origin = self.subviewThumbContainer.frame.origin;
    self.subviewThumbContainer.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
    self.subviewThumbImage.center = CGPointMake(size.width/2, size.height/2);
}

- (UIImage *)_getImageWithCurrentStateFromDictionary:(NSDictionary *)dictionary
{
    UIImage *image = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:TintState]];
    if (image) {
        return image;
    }
    return [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:self.state]];
}

- (void)_setImage:(UIImage *)image forSubview:(UIImageView *)subview
{
    if (subview.image != image) {
        subview.image = image;
        subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y,
                                   image.size.width, image.size.height);
    }
}

#pragma mark - for bounds.

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    return CGRectZero;
}

#pragma mark - basic appearance implements.

static UIImage *DefaultThumb = nil;
static UIImage *DefaultMinimumTrack = nil;
static UIImage *DefaultMaximumTrack = nil;

+ (void)_initializeDefaultImages
{
    DefaultThumb = [UISlider _createDefaultThumbWithTintColor:DefaultThumbColor];
    DefaultMinimumTrack = [UISlider _createDefaultThumbWithTintColor:DefaultMinimumTrackColor];
    DefaultMaximumTrack = [UISlider _createDefaultThumbWithTintColor:DefaultMaximumTrackColor];
}

+ (UIImage *)_getDefaultThumbWithTintColor:(UIColor *)color
{
    if ([color isEqualTo:DefaultThumbColor]) {
        return DefaultThumb;
    }
    return [self _createDefaultThumbWithTintColor:color];
}

+ (UIImage *)_getDefaultMinimumTrackWithTintColor:(UIColor *)color
{
    if ([color isEqualTo:DefaultMinimumTrackColor]) {
        return DefaultMinimumTrack;
    }
    return [self _createDefaultMinimumTrackWithTintColor:color];
}

+ (UIImage *)_getDefaultMaximumTrackWithTintColor:(UIColor *)color
{
    if ([color isEqualTo:DefaultMaximumTrackColor]) {
        return DefaultMaximumTrack;
    }
    return [self _createDefaultMaximumTrackWithTintColor:color];
}

+ (UIImage *)_createDefaultThumbWithTintColor:(UIColor *)color
{
    CGSize imageSize = DefaultThumbImageSize;
    return [UISlider _createImageWithSize:imageSize andDrawIn:^(CGContextRef context) {
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextSetStrokeColorWithColor(context, DefaultStrokeColor);
        CGContextSetLineWidth(context, DefaultLineWith);
        
        CGRect rect = CGRectMake(DefaultLineWith, DefaultLineWith,
                                 imageSize.width - 2*DefaultLineWith, imageSize.height - 2*DefaultLineWith);
        CGContextAddEllipseInRect(context, rect);
        CGContextDrawPath(context, kCGPathFillStroke);
    }];
}

+ (UIImage *)_createDefaultMinimumTrackWithTintColor:(UIColor *)color
{
    CGSize imageSize = DefaultMinimumTrackSize;
    return [UISlider _createImageWithSize:imageSize andDrawIn:^(CGContextRef context) {
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height));
    }];
}

+ (UIImage *)_createDefaultMaximumTrackWithTintColor:(UIColor *)color
{
    CGSize imageSize = DefaultMaximumTrackSize;
    return [UISlider _createImageWithSize:imageSize andDrawIn:^(CGContextRef context) {
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height));
    }];
}

+ (UIImage *)_createImageWithSize:(CGSize)size andDrawIn:(void (^)(CGContextRef))drawInContext
{
    UIGraphicsBeginImageContextWithOptions(size, DefaultSubviewIsOpaque, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    drawInContext(context);
    CGContextRestoreGState(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - util function.

- (float)_getTrackCanMoveWidth
{
    return self.bounds.size.width - self.subviewThumbImage.bounds.size.width;
}

- (float)_getTrackTotalWidth
{
    return self.bounds.size.width;
}

@end
