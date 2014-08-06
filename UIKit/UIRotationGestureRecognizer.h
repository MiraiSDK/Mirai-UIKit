//
//  TNRotationGestureRecognizer.h
//  DupAnimation
//
//  Created by Chen Yonghui on 8/5/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIGestureRecognizer.h>

@interface UIRotationGestureRecognizer : UIGestureRecognizer

@property (nonatomic) CGFloat rotation;
@property (nonatomic,readonly) CGFloat velocity;

@end
