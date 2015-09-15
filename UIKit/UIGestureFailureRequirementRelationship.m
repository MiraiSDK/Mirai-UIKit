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

@end
