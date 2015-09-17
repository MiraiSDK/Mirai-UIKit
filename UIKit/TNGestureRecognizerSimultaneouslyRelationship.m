//
//  UIGestureRecognizerSimultaneouslyGroup.m
//  UIKit
//
//  Created by TaoZeyu on 15/9/9.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNGestureRecognizerSimultaneouslyRelationship.h"

#import "UIView.h"
#import "UIGestureRecognizer+UIPrivate.h"

@implementation TNGestureRecognizerSimultaneouslyRelationship
{
    TNGestureRecognizeProcess *_gestureReconizeProcess;
    
    NSSet *_currentChoosedGroup;
    NSMutableSet *_allSimulataneouslyGroups;
    NSMutableDictionary *_recognizerToGroupDictionary;
    NSArray *_allGestureRecognizersCache;
}

- (instancetype)initWithView:(UIView *)view
     gestureRecongizeProcess:(TNGestureRecognizeProcess *)gestureReconizeProcess
{
    if (self = [self init]) {
        _gestureReconizeProcess = gestureReconizeProcess;
        _allSimulataneouslyGroups = [NSMutableSet set];
        _recognizerToGroupDictionary = [NSMutableDictionary dictionary];
        [self _collectGestureRecognizersWithView:view];
    }
    return self;
}

- (void)dealloc
{
    [self eachGestureRecognizer:^(UIGestureRecognizer *recognizer) {
        [recognizer _unbindRecognizeProcess];
    }];
}

#pragma mark - read properties.

- (NSUInteger)count
{
    return _recognizerToGroupDictionary.count;
}

- (void)chooseSimultaneouslyGroupWhoIncludes:(UIGestureRecognizer *)recongizer
{
    _currentChoosedGroup = [self simultaneouslyGroupIncludes:recongizer];
}

- (BOOL)hasChoosedAnySimultaneouslyGroup
{
    return _currentChoosedGroup != nil;
}

- (BOOL)canRecongizerBeHandledSimultaneously:(UIGestureRecognizer *)recongizer
{
    if (_currentChoosedGroup) {
        return [_currentChoosedGroup containsObject:recongizer];
    } else {
        return YES;
    }
}

- (void)_clearChoosedSimultaneouslyGroup
{
    _currentChoosedGroup = nil;
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
        [recognizer _unbindRecognizeProcess];
    }
    [self _clearCache];
}

- (void)removeSimultaneouslyGroup:(NSSet *)group
{
    for (UIGestureRecognizer *recognizer in group) {
        NSValue *recognizerKey = [NSValue valueWithNonretainedObject:recognizer];
        [_recognizerToGroupDictionary removeObjectForKey:recognizerKey];
        [recognizer _unbindRecognizeProcess];
    }
    [_allSimulataneouslyGroups removeObject:group];
    
    if (_currentChoosedGroup == group) {
        [self _clearChoosedSimultaneouslyGroup];
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
                [recognizer _unbindRecognizeProcess];
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

- (void)eachGestureRecognizerThatNotChoosed:(void (^)(UIGestureRecognizer *recognizer))blockMethod
{
    for (NSMutableSet *group in _allSimulataneouslyGroups) {
        if (group != _currentChoosedGroup) {
            for (UIGestureRecognizer *recognizer in group) {
                blockMethod(recognizer);
            }
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
    NSArray *recongizers = view.gestureRecognizers;
    
    for (UIGestureRecognizer *recongizer in recongizers) {
        [recongizer _bindRecognizeProcess:_gestureReconizeProcess];
    }
    
    for (UIGestureRecognizer *r0 in recongizers) {
        for (UIGestureRecognizer *r1 in recongizers) {
            if (r0 != r1) {
                [self _findRecongizer0:r0 recongizer1:r1];
            }
        }
    }
    
    for (UIGestureRecognizer *recongizer in recongizers) {
        if (![self simultaneouslyGroupIncludes:recongizer]) {
            NSMutableSet *singleGroup = [[NSMutableSet alloc] initWithObjects:recongizer, nil];
            [self _saveGroup:singleGroup forRecognizer:recongizer];
            [_allSimulataneouslyGroups addObject:singleGroup];
        }
    }
}

- (void)_findRecongizer0:(UIGestureRecognizer *)r0 recongizer1:(UIGestureRecognizer *)r1
{
    if ([self _isRecongizer:r0 shouldRecongizeSimultaneouslyWithRecongizer:r1]) {
        
        NSMutableSet *group0 = (NSMutableSet *)[self simultaneouslyGroupIncludes:r0];
        NSMutableSet *group1 = (NSMutableSet *)[self simultaneouslyGroupIncludes:r1];
        
        [self _standardizeGroup0:&group0 group1:&group1];
        
        if (group0 == nil && group1 == nil) {
            NSMutableSet *group = [[NSMutableSet alloc] initWithObjects:r0, r1, nil];
            [self _saveGroup:group forRecognizer:r0];
            [self _saveGroup:group forRecognizer:r1];
            [_allSimulataneouslyGroups addObject:group];
            
        } else if (group0 != nil && group1 == nil) {
            [group0 addObject:r1];
            [self _saveGroup:group0 forRecognizer:r1];
            
        } else if (group0 != nil && group1 != nil) {
            
            if (group0 != group1) {
                for (UIGestureRecognizer *otherRecongizer in group1) {
                    [group0 addObject:otherRecongizer];
                    [self _saveGroup:group0 forRecognizer:otherRecongizer];
                }
                [_allSimulataneouslyGroups removeObject:group1];
            }
            
        } else {
            NSLog(@"ERROR: Invalid Condition!");
        }
    }
}

- (void)_standardizeGroup0:(NSMutableSet **)group0 group1:(NSMutableSet **)group1
{
    NSUInteger count0 = 0;
    NSUInteger count1 = 0;
    
    if (*group0) {
        count0 = (*group0).count;
    }
    if (*group1) {
        count1 = (*group1).count;
    }
    
    if (count0 < count1) {
        NSMutableSet *temp = *group0;
        *group0 = *group1;
        *group1 = temp;
    }
}

- (BOOL)_isRecongizer:(UIGestureRecognizer *)r0 shouldRecongizeSimultaneouslyWithRecongizer:(UIGestureRecognizer *)r1
{
    if (!r0.delegate ||
        [r0.delegate respondsToSelector:@selector(gestureRecognizer:shouldRecongizeSimultaneouslyWithRecongizer:)]) {
        return NO;
    }
    return [r0.delegate gestureRecognizer:r0 shouldRecognizeSimultaneouslyWithGestureRecognizer:r1];
}

- (void)_saveGroup:(NSSet *)group forRecognizer:(UIGestureRecognizer *)recognizer
{
    NSValue *recognizerKey = [NSValue valueWithNonretainedObject:recognizer];
    [_recognizerToGroupDictionary setObject:group forKey:recognizerKey];
}

@end
