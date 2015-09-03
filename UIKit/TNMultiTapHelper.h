//
//  TNMultiTapHelper.h
//  UIKit
//
//  Created by TaoZeyu on 15/9/3.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIGestureRecognizer.h"

@interface TNMultiTapHelper : NSObject

@property (nonatomic, assign) NSUInteger numberOfTapsRequired;

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                   gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

- (void)beginOneTap;
- (void)cancelTap;
- (void)completeOneTap;
- (void)reset;

@end
