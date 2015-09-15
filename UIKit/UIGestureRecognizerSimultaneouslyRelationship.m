//
//  UIGestureRecognizerSimultaneouslyGroup.m
//  UIKit
//
//  Created by TaoZeyu on 15/9/9.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGestureRecognizerSimultaneouslyRelationship.h"

#import "UIView.h"
#import "UIGestureRecognizer+UIPrivate.h"

@implementation UIGestureRecognizerSimultaneouslyRelationship
{
    NSSet *_currentChoosedGroup;
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
        [self _chooseNextSimulatneouslyGroup];
    }
    return self;
}

#pragma mark - read properties.

- (NSUInteger)count
{
    return _recognizerToGroupDictionary.count;
}

- (NSUInteger)choosedSimulataneouslyRecognizersCount
{
    if (!_currentChoosedGroup) {
        return 0;
    }
    return _currentChoosedGroup.count;
}

- (NSSet *)choosedSimultaneouslyGroup
{
    return _currentChoosedGroup;
}

- (void)giveUpCurrentSimultaneouslyGroup
{
    if (_currentChoosedGroup) {
        [self removeSimultaneouslyGroup:_currentChoosedGroup];
        [self _chooseNextSimulatneouslyGroup];
    }
}

- (void)_chooseNextSimulatneouslyGroup
{
    if (_allSimulataneouslyGroups.count > 0) {
        _currentChoosedGroup = [_allSimulataneouslyGroups anyObject];
    } else {
        _currentChoosedGroup = nil;
    }
}

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
    [self _clearCache];
}

- (void)removeSimultaneouslyGroup:(NSSet *)group
{
    for (UIGestureRecognizer *recognizer in group) {
        NSValue *recognizerKey = [NSValue valueWithNonretainedObject:recognizer];
        [_recognizerToGroupDictionary removeObjectForKey:recognizerKey];
    }
    [_allSimulataneouslyGroups removeObject:group];
    
    if (_currentChoosedGroup == group) {
        [self _chooseNextSimulatneouslyGroup];
    }
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
    [self _clearCache];
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

- (UIGestureRecognizer *)findGestureRecognizer:(BOOL (^)(UIGestureRecognizer *recognizer))finderMethod
{
    for (NSMutableSet *group in _allSimulataneouslyGroups) {
        for (UIGestureRecognizer *recognizer in group) {
            if (finderMethod(recognizer)) {
                return recognizer;
            }
        }
    }
    return nil;
}

- (void)_clearCache
{
    _allGestureRecognizersCache = nil;
}

#pragma mark collect gesture recognizers

- (void)_collectGestureRecognizersWithView:(UIView *)view
{
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        NSMutableSet *group = [NSMutableSet set];
        [self _collectAllRecognizersWhoRequireFailTo:recognizer into:group];
        if (group.count > 0) {
            [_allSimulataneouslyGroups addObject:group];
        }
    }
}

- (void)_collectAllRecognizersWhoRequireFailTo:(UIGestureRecognizer *)recognizer
                                          into:(NSMutableSet *)group
{
    if (![group containsObject:recognizer]) {
        
        NSSet *originalGroup = [self simultaneouslyGroupIncludes:recognizer];
        
        if (originalGroup) {
            for (UIGestureRecognizer *otherRecognizer in originalGroup) {
                [self _saveGroup:group forRecognizer:otherRecognizer];
            }
            [_allSimulataneouslyGroups removeObject:originalGroup];
            [group unionSet:originalGroup];
            
        } else {
            [self _saveGroup:group forRecognizer:recognizer];
            [group addObject:recognizer];
        }
        
//        for (UIGestureRecognizer *afterFailRecognizer in [recognizer _recognizersWhoRequireThisToFail]) {
//            [self _collectAllRecognizersWhoRequireFailTo:afterFailRecognizer into:group];
//        }
    }
}

- (void)_saveGroup:(NSSet *)group forRecognizer:(UIGestureRecognizer *)recognizer
{
    NSValue *recognizerKey = [NSValue valueWithNonretainedObject:recognizer];
    [_recognizerToGroupDictionary setObject:group forKey:recognizerKey];
}

@end
