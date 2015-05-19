//
//  UIMenuBubbleView.m
//  UIKit
//
//  Created by TaoZeyu on 15/5/19.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIMenuBubbleView.h"

#define kArrowWidth 5
#define kArrowHeight 26

@interface UIMenuBubbleView ()
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic) UIMenuControllerArrowDirection arrowAppearanceDirection;
@property (nonatomic, weak) UIMenuController *parentMenuController;
@property (nonatomic, weak) UIWindow *currentWindow;
@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, strong) UIView *arrowView;
@end

@implementation UIMenuBubbleView

- (instancetype)initWithParent:(UIMenuController *)parentMenuController
{
    if (self = [super initWithFrame:CGRectZero]) {
        self.parentMenuController = parentMenuController;
        [self _setDefaultValues];
        [self _setAutoresizeMask];
        [self _makeSubviews];
    }
    return self;
}

- (void)_setDefaultValues
{
    _menuItems = @[];
}

- (void)_setAutoresizeMask
{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setKeyWindowTargetRect:(CGRect)targetRect
{
    _keyWindowTargetRect = targetRect;
    [self _setDirectionAndArrowPositionByGapSpace];
}

- (void)_onTappedSpaceOnCurrentWindow
{
    [self.parentMenuController setMenuVisible:NO animated:YES];
}

- (UIView *)_getScreen
{
    return self.superview;
}

#pragma mark - choose appropriate arrow location and direction.

- (void)_setDirectionAndArrowPositionByGapSpace
{
    NSArray *arrowDirectionList = [self _testArrowDirectionListWithStartDirection:self.parentMenuController.arrowDirection];
    for (NSNumber *directionPackage in arrowDirectionList) {
        UIMenuControllerArrowDirection direction = [directionPackage integerValue];
        CGRect bubbleCoverArea = [self _getMenuBubbleCoverAreaWithDirection:direction];
        if (CGRectContainsRect([self _getScreen].bounds, bubbleCoverArea)) {
            [self _setArrowPositionWithDirection:direction];
            return;
        }
    }
    [self _setArrowPositionAtCenter];
}

- (NSArray *)_testArrowDirectionListWithStartDirection:(UIMenuControllerArrowDirection)startDirection
{
    if (startDirection == UIMenuControllerArrowDefault) {
        startDirection = UIMenuControllerArrowUp;
    }
    static NSDictionary *startDirection2TestList;
    if (startDirection2TestList == nil) {
        startDirection2TestList = @{
            @(UIMenuControllerArrowUp):@[
                    @(UIMenuControllerArrowUp),
                    @(UIMenuControllerArrowDown),
                    @(UIMenuControllerArrowLeft),
                    @(UIMenuControllerArrowRight),
                    ],
            @(UIMenuControllerArrowDown):@[
                    @(UIMenuControllerArrowDown),
                    @(UIMenuControllerArrowUp),
                    @(UIMenuControllerArrowLeft),
                    @(UIMenuControllerArrowRight),
                    ],
            @(UIMenuControllerArrowLeft):@[
                    @(UIMenuControllerArrowLeft),
                    @(UIMenuControllerArrowRight),
                    @(UIMenuControllerArrowUp),
                    @(UIMenuControllerArrowDown),
                    ],
            @(UIMenuControllerArrowRight):@[
                    @(UIMenuControllerArrowRight),
                    @(UIMenuControllerArrowLeft),
                    @(UIMenuControllerArrowUp),
                    @(UIMenuControllerArrowDown),
                    ],
            };
    }
    return [startDirection2TestList objectForKey:@(startDirection)];
}

#pragma mark - setting menu bubble appearance.

- (void)_makeSubviews
{
    _bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    _arrowView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _bodyView.backgroundColor = [UIColor blackColor];
    _arrowView.backgroundColor = [UIColor blackColor];
    
    [self addSubview:_bodyView];
    [self addSubview:_arrowView];
}

- (void)_setArrowPositionWithDirection:(UIMenuControllerArrowDirection)direction
{
    _arrowAppearanceDirection = direction;
    [self _moveArrowToPositionPoint:[self _getArrowPositionWithDirection:direction]];
}

- (void)_setArrowPositionAtCenter
{
    _arrowAppearanceDirection = UIMenuControllerArrowUp;
    [self _moveArrowToPositionPoint:CGPointMake(_keyWindowTargetRect.origin.x + _keyWindowTargetRect.size.width/2,
                                                _keyWindowTargetRect.origin.y + _keyWindowTargetRect.size.height/2)];
}

- (CGRect)_getMenuBubbleCoverAreaWithDirection:(UIMenuControllerArrowDirection)direction
{
    CGSize coverSize = [self _getMenuBubbleNeedAreaWithDirection:direction];
    CGPoint arrowPosition = [self _getArrowPositionWithDirection:direction];
    
    switch (direction) {
        case UIMenuControllerArrowUp:
        case UIMenuControllerArrowLeft:
        case UIMenuControllerArrowRight:
            return CGRectMake(arrowPosition.x - coverSize.width/2, arrowPosition.y - coverSize.height,
                              coverSize.width, coverSize.height);
            
        case UIMenuControllerArrowDown:
            return CGRectMake(arrowPosition.x - coverSize.width/2, arrowPosition.y,
                              coverSize.width, coverSize.height);
            
        default:
            return CGRectNull;
    }
}

- (CGSize)_getMenuBubbleNeedAreaWithDirection:(UIMenuControllerArrowDirection)direction
{
    return CGSizeMake(_bodyView.bounds.size.width, _bodyView.bounds.size.height + kArrowHeight);
}

- (CGPoint)_getArrowPositionWithDirection:(UIMenuControllerArrowDirection)direction
{
    CGSize targetSize = _keyWindowTargetRect.size;
    CGPoint targetOrigin = _keyWindowTargetRect.origin;
    
    switch (direction) {
        case UIMenuControllerArrowUp:
            return CGPointMake(targetOrigin.x + targetSize.width/2, targetOrigin.y);
            
        case UIMenuControllerArrowDown:
            return CGPointMake(targetOrigin.x + targetSize.width/2, targetOrigin.y + targetSize.height);
            
        case UIMenuControllerArrowLeft:
            return CGPointMake(targetOrigin.x - _bodyView.bounds.size.width/2,
                               targetOrigin.y + targetSize.height/2);
            
        case UIMenuControllerArrowRight:
            return CGPointMake(targetOrigin.x + _bodyView.bounds.size.width/2 + targetSize.width,
                               targetOrigin.y + targetSize.height/2);
            
        default:
            return CGPointZero;
    }
}

- (void)_moveArrowToPositionPoint:(CGPoint)position
{
    switch (_arrowAppearanceDirection) {
        case UIMenuControllerArrowUp:
        case UIMenuControllerArrowLeft:
        case UIMenuControllerArrowRight:
        case UIMenuControllerArrowDefault:
            _bodyView.frame = CGRectMake(position.x - _bodyView.frame.size.width/2,
                                         position.y - _bodyView.frame.size.height - kArrowHeight,
                                         _bodyView.frame.size.width, _bodyView.frame.size.height);
            _arrowView.frame = CGRectMake(position.x - kArrowWidth/2, position.y - kArrowHeight,
                                          kArrowWidth, kArrowHeight);
            break;
            
        case UIMenuControllerArrowDown:
            _bodyView.frame = CGRectMake(position.x - _bodyView.frame.size.width/2, position.y + kArrowHeight,
                                         _bodyView.frame.size.width, _bodyView.frame.size.height);
            _arrowView.frame = CGRectMake(position.x - kArrowWidth/2, position.y,
                                          kArrowWidth, kArrowHeight);
            break;
    }
}

@end
