//
//  UIGestureFailureRequirementRelationship.m
//  UIKit
//
//  Created by TaoZeyu on 15/9/15.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNGestureFailureRequirementRelationship.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIView.h"

@implementation TNGestureFailureRequirementRelationship
{
    NSMutableDictionary *_recongizerToItsFailureRequiresSet;
}

- (instancetype)initWithView:(UIView *)view
{
    if (self = [self init]) {
        _recongizerToItsFailureRequiresSet = [NSMutableDictionary dictionary];
        
        NSArray *recognizers = view.gestureRecognizers;
        [self _recordFailureRequirementFromCallingMethodWithRecognizers:recognizers];
        [self _recordFailureRequirementFromOverrideMethodWithRecognizers:recognizers];
    }
    return self;
}

- (void)_recordFailureRequirementFromCallingMethodWithRecognizers:(NSArray *)recognizers
{
    for (UIGestureRecognizer *recongizer in recognizers) {
        UIGestureRecognizer *requireToFailRecognizer = [recongizer _requireToFailRecognizer];
        if (requireToFailRecognizer) {
            [self _recordRecognizer:recongizer requireOtherToFail:requireToFailRecognizer];
        }
    }
}

- (void)_recordFailureRequirementFromOverrideMethodWithRecognizers:(NSArray *)recognizers
{
    for (UIGestureRecognizer *requireToFailRecognizer in recognizers) {
        for (UIGestureRecognizer *recongizer in recognizers) {
            if ([self _recognizer:recongizer requireThisRecognizerToFail:requireToFailRecognizer]) {
                [self _recordRecognizer:recongizer requireOtherToFail:requireToFailRecognizer];
            }
        }
    }
}

- (BOOL)_recognizer:(UIGestureRecognizer *)recognizer requireThisRecognizerToFail:(UIGestureRecognizer *)requireToFailRecognizer
{
    if (recognizer == requireToFailRecognizer) {
        return NO;
    }
    
    if (![requireToFailRecognizer shouldBeRequiredToFailByGestureRecognizer:recognizer]) {
        return NO;
    }
    
    if (![recognizer shouldRequireFailureOfGestureRecognizer:requireToFailRecognizer]) {
        return NO;
    }
    
    if ([requireToFailRecognizer.delegate respondsToSelector:@selector(gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:)] &&
        ![requireToFailRecognizer.delegate gestureRecognizer:requireToFailRecognizer shouldBeRequiredToFailByGestureRecognizer:recognizer]) {
        return NO;
    }
    
    if ([recognizer.delegate respondsToSelector:@selector(shouldRequireFailureOfGestureRecognizer:)] &&
        ![recognizer shouldRequireFailureOfGestureRecognizer:requireToFailRecognizer]) {
        return NO;
    }
    
    return YES;
}

- (void)_recordRecognizer:(UIGestureRecognizer *)recognizer
       requireOtherToFail:(UIGestureRecognizer *)requireToFailRecognizer
{
    NSValue *key = [NSValue valueWithNonretainedObject:requireToFailRecognizer];
    NSMutableSet *failureRequires = [_recongizerToItsFailureRequiresSet objectForKey:key];
    if (!failureRequires) {
        failureRequires = [NSMutableSet set];
        [_recongizerToItsFailureRequiresSet setObject:failureRequires forKey:key];
    }
    [failureRequires addObject:recognizer];
}

- (void)eachGestureRecongizer:(UIGestureRecognizer *)gestureRecongizer
                     requires:(void (^)(UIGestureRecognizer *))eachBlock
{
    NSValue *key = [NSValue valueWithNonretainedObject:gestureRecongizer];
    NSMutableSet *set = [_recongizerToItsFailureRequiresSet objectForKey:key];
    
    if (set) {
        for (UIGestureRecognizer *recongizer in set) {
            eachBlock(recongizer);
        }
    }
}

- (void)recursiveSearchFromRecongizer:(UIGestureRecognizer *)root
                             requires:(void (^)(UIGestureRecognizer *))eachBlock
{
    BOOL (^alwaysYesCondition)(UIGestureRecognizer *) = ^BOOL(UIGestureRecognizer *recongizer) {
        return YES;
    };
    [self recursiveSearchFromRecongizer:root recursiveCondition:alwaysYesCondition requires:eachBlock];
}

- (void)recursiveSearchFromRecongizer:(UIGestureRecognizer *)root
                   recursiveCondition:(BOOL (^)(UIGestureRecognizer *))conditionBlock
                             requires:(void (^)(UIGestureRecognizer *))eachBlock
{
    // the next line is a recursion invoking.
    // but UIGestureRecognizer requireGestureRecognizerToFail relationship may have Ring in them.
    // Ring will make a death-recursion invoking.
    // So, I make a exceptSet to exclude duplicated UIGestureRecognizer objects.
    
    NSMutableSet *exceptSet = [NSMutableSet set];
    [self _recursiveSearchFromRecongizer:root recursiveCondition:conditionBlock
                                requires:eachBlock exceptSet:exceptSet];
}

- (void)_recursiveSearchFromRecongizer:(UIGestureRecognizer *)startRecongizer
                    recursiveCondition:(BOOL (^)(UIGestureRecognizer *))conditionBlock
                              requires:(void (^)(UIGestureRecognizer *))eachBlock
                             exceptSet:(NSMutableSet *)exceptSet
{
    if (![exceptSet containsObject:startRecongizer]) {
        [exceptSet addObject:startRecongizer];
        
        eachBlock(startRecongizer);
        
        if (conditionBlock(startRecongizer)) {
            
            NSValue *key = [NSValue valueWithNonretainedObject:startRecongizer];
            NSMutableSet *set = [_recongizerToItsFailureRequiresSet objectForKey:key];
            
            if (set) {
                for (UIGestureRecognizer *recongizer in set) {
                    [self _recursiveSearchFromRecongizer:recongizer recursiveCondition:conditionBlock
                                                requires:eachBlock exceptSet:exceptSet];
                }
            }
        }
    }
}

@end
