//
//  TNGestureRecognizerMath.m
//  DupAnimation
//
//  Created by Chen Yonghui on 8/5/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNGestureRecognizerMath.h"

CGFloat CGPointDistance(CGPoint p1, CGPoint p2)
{
    return fabs(hypot(p1.x - p2.x, p1.y - p2.y));
}
