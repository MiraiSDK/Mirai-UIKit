//
//  UIGestureFailureRequirementRelationship.m
//  UIKit
//
//  Created by TaoZeyu on 15/9/15.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGestureFailureRequirementRelationship.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UIView.h"

@implementation UIGestureFailureRequirementRelationship
{
    NSMutableDictionary *_recongizerToItsFailureRequiresSet;
}

- (instancetype)initWithView:(UIView *)view
{
    if (self = [self init]) {
        _recongizerToItsFailureRequiresSet = [NSMutableDictionary dictionary];
        for (UIGestureRecognizer *recongizer in view.gestureRecognizers) {
            [self _recordAndHandleGestureRecongizer:recongizer];
        }
    }
    return self;
}

- (void)_recordAndHandleGestureRecongizer:(UIGestureRecognizer *)recongizer
{
    UIGestureRecognizer *requireToFailRecongizer = [recongizer _requireToFailRecognizer];
    
    if (requireToFailRecongizer) {
        NSMutableSet *failureRequires = [self _allRecongizersWhoRequireToFail:requireToFailRecongizer];
        [failureRequires addObject:recongizer];
    }
}

- (NSMutableSet *)_allRecongizersWhoRequireToFail:(UIGestureRecognizer *)requireToFailRecongizer
{
    NSValue *key = [NSValue valueWithNonretainedObject:requireToFailRecongizer];
    NSMutableSet *set = [_recongizerToItsFailureRequiresSet objectForKey:key];
    if (!set) {
        set = [NSMutableSet set];
        [_recongizerToItsFailureRequiresSet setObject:set forKey:key];
    }
    return set;
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
