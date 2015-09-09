//
//  UIGestureRecognizerSimultaneouslyGroup.m
//  UIKit
//
//  Created by TaoZeyu on 15/9/9.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGestureRecognizerSimultaneouslyGroup.h"

#import "UIView.h"
#import "UIGestureRecognizer+UIPrivate.h"

@implementation UIGestureRecognizerSimultaneouslyGroup
{
    NSMutableSet *_allSimulataneouslyGroups;
    NSMutableDictionary *_recognizerToGroupDictionary;
    NSArray *_allGestureRecognizersCache;
}

- (instancetype)initWithView:(UIView *)view
{
    if (self = [self init]) {
        _allSimulataneouslyGroups = [NSMutableSet set];
        _recognizerToGroupDictionary = [NSMutableDictionary dictionary];
        [self _collectGestureRecognizersWithView:view];
    }
    return self;
}

#pragma mark - read properties.

- (void)removeGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    NSValue *recognizerKey = [NSValue valueWithNonretainedObject:recognizer];
    NSMutableSet *includesRecognizerGroup = [_recognizerToGroupDictionary objectForKey:recognizerKey];
    
    if (includesRecognizerGroup) {
        [_recognizerToGroupDictionary removeObjectForKey:recognizerKey];
        [includesRecognizerGroup removeObject:recognizer];
        
        if (includesRecognizerGroup.count == 0) {
            [_allSimulataneouslyGroups removeObject:includesRecognizerGroup];
        }
    }
    _allGestureRecognizersCache = nil;
}

- (void)removeWithCondition:(BOOL (^)(UIGestureRecognizer *))conditionMethod
{
    NSMutableSet *groupToRemove = [NSMutableSet set];
    
    for (NSMutableSet *group in _allSimulataneouslyGroups) {
        NSMutableSet *recognizerToRemove = [NSMutableSet set];
        for (UIGestureRecognizer *recognizer in group) {
            if (conditionMethod(recognizer)) {
                [recognizerToRemove addObject:recognizer];
                NSValue *recognizerKey = [NSValue valueWithNonretainedObject:recognizer];
                [_recognizerToGroupDictionary removeObjectForKey:recognizerKey];
            }
        }
        [group minusSet:recognizerToRemove];
        if (group.count == 0) {
            [groupToRemove addObject:group];
        }
    }
    _allGestureRecognizersCache = nil;
}

- (NSSet *)allSimulataneouslyGroups
{
    return _allSimulataneouslyGroups;
}

- (NSArray *)allGestureRecognizers
{
    if (_allGestureRecognizersCache) {
        return _allGestureRecognizersCache;
    }
    NSMutableArray *cache = [NSMutableArray array];
    
    for (NSMutableSet *group in _allSimulataneouslyGroups) {
        for (UIGestureRecognizer *recognizer in group) {
            [cache addObject:recognizer];
        }
    }
    _allGestureRecognizersCache = cache;
    return cache;
}

- (NSSet *)simultaneouslyGroupIncludes:(UIGestureRecognizer *)recognizer
{
    return [_recognizerToGroupDictionary objectForKey:[NSValue valueWithNonretainedObject:recognizer]];
}

- (void)eachGestureRecognizer:(void (^)(UIGestureRecognizer *recognizer))blockMethod
{
    for (NSMutableSet *group in _allSimulataneouslyGroups) {
        for (UIGestureRecognizer *recognizer in group) {
            blockMethod(recognizer);
        }
    }
}

#pragma mark collect gesture recognizers

- (void)_collectGestureRecognizersWithView:(UIView *)view
{
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        NSMutableSet *group = [NSMutableSet set];
        [self _collectAllRecognizersWhoRequireFailTo:recognizer into:group];
    }
}

- (void)_collectAllRecognizersWhoRequireFailTo:(UIGestureRecognizer *)recognizer
                                          into:(NSMutableSet *)group
{
    if (![group containsObject:recognizer]) {
        
        BOOL success = [self _recordRecognizer:recognizer withGroup:group];
        if (success) {
            [group addObject:recognizer];
            for (UIGestureRecognizer *afterFailRecognizer in [recognizer _recognizersWhoRequireThisToFail]) {
                [self _collectAllRecognizersWhoRequireFailTo:afterFailRecognizer into:group];
            }
        }
    }
}

- (BOOL)_recordRecognizer:(UIGestureRecognizer *)recognizer withGroup:(NSMutableSet *)group
{
    NSValue *recognizerKey = [NSValue valueWithNonretainedObject:recognizer];
    
    if ([_recognizerToGroupDictionary objectForKey:recognizerKey]) {
        return NO;
    }
    [_recognizerToGroupDictionary setObject:group forKey:recognizerKey];
    return YES;
}

@end
