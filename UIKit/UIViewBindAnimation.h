//
//  UIViewBindAnimation.h
//  UIKit
//
//  Created by TaoZeyu on 15/12/1.
//  Copyright © 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewAnimationGroup;
@class UIView;
@class CAAnimation;

@interface UIViewBindAnimation : NSObject

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) NSUInteger animationsCount;

- (instancetype)initWithView:(UIView *)view;
- (CAAnimation *)setAnimation:(CAAnimation *)animation withKeyPath:(NSString *)keyPath
                           by:(UIViewAnimationGroup *)viewAnimationGroup;
- (void)removeAnimation:(CAAnimation *)animation by:(UIViewAnimationGroup *)viewAnimationGroup;
- (void)removeAllAnimationsOfViewAnimationGroup:(UIViewAnimationGroup *)viewAnimationGroup;
- (void)removeAllAnimations;
- (void)removeAllAnimationsAndNotifViewAnimationGroup;

@end
