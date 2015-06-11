//
//  UIBubbleView.m
//  UIKit
//
//  Created by TaoZeyu on 15/5/31.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIBubbleView.h"

#define kDefaultTintColor [UIColor blackColor]
#define kDefaultBodyPadding UIEdgeInsetsMake(0, 0, 0, 0)
#define kDefaultArrowSize CGSizeMake(35, 35)
#define kDefaultContainerSize CGSizeMake(100, 100)
#define kDefaultArrowPosition CGPointZero
#define kDefaultArrowPossitionOnRect [UIPositionOnRect positionOnRectWithPositionScale:1.0 withBorderDirection:UIPositionOnRectDirectionUp]
#define kAnimateDuration 0.5

@interface UIArrowBodyView : UIView

@property (nonatomic) UIPositionOnRectDirection direction;

@end

@implementation UIArrowBodyView

- (instancetype)init
{
    if (self = [super init]) {
        _direction = UIPositionOnRectDirectionDown;
    }
    return self;
}

- (void)setDirection:(UIPositionOnRectDirection)direction
{
    if (_direction != direction) {
        _direction = direction;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    [self _drawArrowPathWithContext:context withRect:rect];
    CGContextClosePath(context);
    [self.tintColor setFill];
    CGContextDrawPath(context,kCGPathFillStroke);
}

- (void)_drawArrowPathWithContext:(CGContextRef)context withRect:(CGRect)rect
{
    switch (_direction) {
        case UIPositionOnRectDirectionUp:
            CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width/2, rect.origin.y);
            break;
            
        case UIPositionOnRectDirectionDown:
            CGContextMoveToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
            CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height);
            break;
            
        case UIPositionOnRectDirectionLeft:
            CGContextMoveToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
            CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height/2);
            break;
            
        case UIPositionOnRectDirectionRight:
            CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height/2);
            CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
            break;
            
        default:
            NSLog(@"unknow direction %li", _direction);
            break;
    }
}

@end

@interface UIBubbleView ()
{
    UIView *_bubbleBodyView;
    UIArrowBodyView *_arrowBodyView;
}
@end

@implementation UIBubbleView

#pragma mark - init

- (instancetype)init
{
    return [self initWithContainer:[[UIView alloc] init]];
}

- (instancetype)initWithContainer:(UIView *)container
{
    if (self = [super init]) {
        _container = container;
        [self _configureSubviews];
        [self _setDefaultPropertyValues];
        [self refreshBubbleAppearance];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshBubbleAppearance];
}

- (void)_setDefaultPropertyValues
{
    self.tintColor = kDefaultTintColor;
    _bodyPadding = kDefaultBodyPadding;
    _arrowSize = kDefaultArrowSize;
    _containerSize = kDefaultContainerSize;
    _arrowPosition = kDefaultArrowPosition;
    _arrowPossitionOnRect = kDefaultArrowPossitionOnRect;
}

#pragma mark - properties setter

- (void)setContainer:(UIView *)container
{
    [self setContainer:container animated:NO];
}

- (void)setContainer:(UIView *)container animated:(BOOL)animated
{
    if (_container != container) {
        [_container removeFromSuperview];
        _container = container;
        [self addSubview:_container];
        [self refreshBubbleAppearance];
    }
}

- (void)setBodyPadding:(UIEdgeInsets)bodyPadding
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_bodyPadding, bodyPadding)) {
        _bodyPadding = bodyPadding;
        [self refreshBubbleAppearance];
    }
}

- (void)setArrowSize:(CGSize)arrowSize
{
    if (!CGSizeEqualToSize(_arrowSize, arrowSize)) {
        _arrowSize = arrowSize;
        [self refreshBubbleAppearance];
    }
}

- (void)setContainerSize:(CGSize)containerSize
{
    [self setContainerSize:containerSize animated:NO];
}

- (void)setContainerSize:(CGSize)containerSize animated:(BOOL)animated
{
    if (!CGSizeEqualToSize(_containerSize, containerSize)) {
        _containerSize = containerSize;
        if (animated) {
            [UIView animateWithDuration:kAnimateDuration animations:^{
                [self refreshBubbleAppearance];
            }];
        } else {
            [self refreshBubbleAppearance];
        }
    }
}

- (void)setArrowPossitionOnRect:(UIPositionOnRect *)arrowPossitionOnRect
{
    if (![_arrowPossitionOnRect isEqual:arrowPossitionOnRect]) {
        _arrowPossitionOnRect = arrowPossitionOnRect;
        [_arrowBodyView setDirection:arrowPossitionOnRect.borderDirection];
        [self refreshBubbleAppearance];
    }
}

- (void)setArrowPosition:(CGPoint)arrowPosition
{
    if (!CGPointEqualToPoint(_arrowPosition, arrowPosition)) {
        _arrowPosition = arrowPosition;
        [self refreshBubbleAppearance];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _bubbleBodyView.backgroundColor = tintColor;
    _arrowBodyView.tintColor = tintColor;
}

#pragma mark - reader

- (CGSize)bubbleSize
{
    return CGSizeMake(_containerSize.width + _bodyPadding.left + _bodyPadding.right,
                      _containerSize.height + _bodyPadding.top + _bodyPadding.bottom);
}

#pragma mark - appearance

- (CGRect)bubbleBodyRectangleWithPositionOnRect:(UIPositionOnRect *)arrowPossitionOnRect
                                     atPosition:(CGPoint)arrowPossition
{
    CGFloat intervalDistance = _arrowSize.width;
    UIPositionOnRectDirection moveDirection = [UIPositionOnRect reverseDirectionOf:
                                               arrowPossitionOnRect.borderDirection];
    arrowPossition = [UIPositionOnRect movePosition:arrowPossition withDistance:intervalDistance
                                      withDirection:moveDirection];
    return [arrowPossitionOnRect findRectangleWithSize:self.bubbleSize linkedToPosition:arrowPossition];
}

- (CGRect)bubbleBodyRectangleWithPositionOnRect:(UIPositionOnRect *)arrowPossitionOnRect
                                         inArea:(CGRect)area
                             areaPositionOnRect:(UIPositionOnRect *)areaPossitionOnRect
{
    CGFloat intervalDistance = _arrowSize.width;
    return [UIPositionOnRect targetRectangleWith:arrowPossitionOnRect size:self.bubbleSize
                                      fromSource:areaPossitionOnRect rectangle:area
                                intervalDistance:intervalDistance];
}

- (void)setPositionCloseToArea:(CGRect)area areaPositionOnRect:(UIPositionOnRect *)areaPossitionOnRect
{
    self.arrowPosition = [areaPossitionOnRect findPositionLinkedToRectangle:area];
}

- (void)_configureSubviews
{
    _bubbleBodyView = [[UIView alloc] init];
    _arrowBodyView = [[UIArrowBodyView alloc] init];
    
    [self addSubview:_bubbleBodyView];
    [self addSubview:_arrowBodyView];
    
    if (_container.superview != self) {
        [self addSubview:_container];
    }
}

- (void)refreshBubbleAppearance
{
    _bubbleBodyView.frame = [self _bubbleBodyRect];
    _arrowBodyView.frame = [self _arrowBodyRect];
    
    [self _adjustSelfAndSubviewsLocation];
}

- (CGRect)_bubbleBodyRect
{
    return [self bubbleBodyRectangleWithPositionOnRect:_arrowPossitionOnRect atPosition:_arrowPosition];
}

- (CGRect)_arrowBodyRect
{
    UIPositionOnRectDirection arrowBodyDirection = [UIPositionOnRect reverseDirectionOf:
                                                    _arrowPossitionOnRect.borderDirection];
    static const CGFloat centerOfBorderScale = 0.5;
    UIPositionOnRect *arrowBodyPoR = [UIPositionOnRect positionOnRectWithPositionScale:centerOfBorderScale
                                                                   withBorderDirection:arrowBodyDirection];
    return [UIPositionOnRect targetRectangleWith:arrowBodyPoR size:_arrowSize
                                      fromSource:_arrowPossitionOnRect rectangle:_bubbleBodyView.frame];
}

- (void)_adjustSelfAndSubviewsLocation
{
    CGRect coverRect = CGRectUnion(_bubbleBodyView.frame, _arrowBodyView.frame);
    [self _adjustToRelativeLocationForSubview:_bubbleBodyView relativeRect:coverRect];
    [self _adjustToRelativeLocationForSubview:_arrowBodyView relativeRect:coverRect];
    [self _adjustContainerLocation];
    [self _adjustSelfLocationWithRelativeRect:coverRect];
}

- (void)_adjustToRelativeLocationForSubview:(UIView *)subview relativeRect:(CGRect)relativeRect
{
    subview.frame = CGRectMake(subview.frame.origin.x - relativeRect.origin.x,
                               subview.frame.origin.y - relativeRect.origin.y,
                               subview.frame.size.width, subview.frame.size.height);
}

- (void)_adjustContainerLocation
{
    _container.frame = CGRectMake(_bubbleBodyView.frame.origin.x + _bodyPadding.left,
                                  _bubbleBodyView.frame.origin.y + _bodyPadding.top,
                                  _containerSize.width, _containerSize.height);
}

- (void)_adjustSelfLocationWithRelativeRect:(CGRect)relativeRect
{
    self.frame = relativeRect;
}

@end
