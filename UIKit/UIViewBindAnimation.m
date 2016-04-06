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

- (CAAnimation *)setAnimation:(CAAnimation *)animation withKeyPath:(NSString *)keyPath
                           by:(UIViewAnimationGroup *)viewAnimationGroup
{
    NSValue *animationGroupKey = [NSValue valueWithNonretainedObject:viewAnimationGroup];
    NSMutableDictionary *animationsWithKeyPath = ({
        NSMutableDictionary *dct = [_animationsDictionary objectForKey:animationGroupKey];
        if (!dct) {
            dct = [[NSMutableDictionary alloc] init];
            [_animationsDictionary setObject:dct forKey:animationGroupKey];
        }
        dct;
    });
    CAAnimation *existAnimation = [animationsWithKeyPath objectForKey:keyPath];
    
    if (!existAnimation) {
        _animationsCount++;
    }
    [animationsWithKeyPath setObject:animation forKey:keyPath];
    
    return existAnimation;
}

- (void)removeAnimation:(CAAnimation *)animation by:(UIViewAnimationGroup *)viewAnimationGroup
{
    NSValue *animationGroupKey = [NSValue valueWithNonretainedObject:viewAnimationGroup];
    NSMutableDictionary *dictionaryWithKeyPath = [_animationsDictionary objectForKey:animationGroupKey];
    if (dictionaryWithKeyPath) {
        
        for (NSString *keyPath in [dictionaryWithKeyPath allKeysForObject:animation]) {
            [dictionaryWithKeyPath removeObjectForKey:keyPath];
            _animationsCount--;
        }
        
        if (dictionaryWithKeyPath.count == 0) {
            [_animationsDictionary removeObjectForKey:animationGroupKey];
            [_viewAnimationGroups removeObject:viewAnimationGroup];
        }
    }
}

- (void)removeAllAnimationsOfViewAnimationGroup:(UIViewAnimationGroup *)viewAnimationGroup
{
    NSValue *animationGroupKey = [NSValue valueWithNonretainedObject:viewAnimationGroup];
    NSMutableDictionary *dictionaryWithKeyPath = [_animationsDictionary objectForKey:animationGroupKey];
    
    if (dictionaryWithKeyPath) {
        _animationsCount -= dictionaryWithKeyPath.count;
        [_animationsDictionary removeObjectForKey:animationGroupKey];
        [_viewAnimationGroups removeObject:viewAnimationGroup];
    }
}

- (void)removeAllAnimationsAndNotifViewAnimationGroup
{
    for (UIViewAnimationGroup *viewAnimationGroup in _viewAnimationGroups) {
        NSValue *animationGroupKey = [NSValue valueWithNonretainedObject:viewAnimationGroup];
        NSMutableDictionary *dictionaryWithKeyPath = [_animationsDictionary objectForKey:animationGroupKey];
        NSArray *removedAnimations = [self _deduplicateArray:[dictionaryWithKeyPath allValues]];
        [viewAnimationGroup viewRemoveFromSuper:_view withRemovedAnimations:removedAnimations];
    }
    [self removeAllAnimations];
}

- (void)removeAllAnimations
{
    [_animationsDictionary removeAllObjects];
    [_viewAnimationGroups removeAllObjects];
    _animationsCount = 0;
}

- (NSUInteger)animationsCount
{
    return _animationsCount;
}

- (NSArray *)_deduplicateArray:(NSArray *)array
{
    NSMutableSet *testSet = [[NSMutableSet alloc] init];
    NSMutableArray *targetArray = [[NSMutableArray alloc] init];
    
    for (id obj in array) {
        if (![testSet containsObject:obj]) {
            [testSet addObject:obj];
            [targetArray addObject:obj];
        }
    }
    return targetArray;
}

@end
