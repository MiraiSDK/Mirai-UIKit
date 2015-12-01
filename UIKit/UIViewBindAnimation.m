//
//  UIViewBindAnimation.m
//  UIKit
//
//  Created by TaoZeyu on 15/12/1.
//  Copyright © 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIViewBindAnimation.h"
#import "UIViewAnimationGroup.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewBindAnimation
{
    __unsafe_unretained UIView *_view;
    
    NSMutableDictionary *_animationsDictionary;
    NSMutableSet *_viewAnimationGroups;
    NSUInteger _animationsCount;
}
- (instancetype)initWithView:(UIView *)view
{
    if (self = [self init]) {
        _view = view;
        _animationsCount = 0;
        _animationsDictionary = [NSMutableDictionary dictionary];
        _viewAnimationGroups = [NSMutableSet set];
    }
    return self;
}

- (void)addAnimation:(CAAnimation *)animation by:(UIViewAnimationGroup *)viewAnimationGroup
{
    NSValue *key = [NSValue valueWithNonretainedObject:viewAnimationGroup];
    NSMutableSet *animations = [_animationsDictionary objectForKey:key];
    if (!animations) {
        animations = [NSMutableSet set];
        [_animationsDictionary setObject:animation forKey:key];
        [_viewAnimationGroups addObject:viewAnimationGroup];
    }
    if ([animations containsObject:animation]) {
        _animationsCount++;
        [animations addObject:animation];
    }
}

- (void)removeAnimation:(CAAnimation *)animation by:(UIViewAnimationGroup *)viewAnimationGroup
{
    NSValue *key = [NSValue valueWithNonretainedObject:viewAnimationGroup];
    NSMutableSet *animations = [_animationsDictionary objectForKey:key];
    if (animations) {
        animations = [NSMutableSet set];
        if ([animations containsObject:animation]) {
            [animations removeObject:animation];
            _animationsCount--;
        }
        if (animations.count == 0) {
            [_animationsDictionary removeObjectForKey:key];
            [_viewAnimationGroups removeObject:viewAnimationGroup];
        }
    }
}

- (void)removeAllAnimations
{
    for (UIViewAnimationGroup *viewAnimationGroup in _viewAnimationGroups) {
        NSValue *key = [NSValue valueWithNonretainedObject:viewAnimationGroup];
        for (CAAnimation *animation in [_animationsDictionary objectForKey: key]) {
            [viewAnimationGroup animationsViewRemoveFromSuper:animation];
        }
    }
    [_animationsDictionary removeAllObjects];
    [_viewAnimationGroups removeAllObjects];
    _animationsCount = 0;
}

- (NSUInteger)animationsCount
{
    return _animationsCount;
}

@end
