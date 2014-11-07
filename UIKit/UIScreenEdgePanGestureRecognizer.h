//
//  UIScreenEdgePanGestureRecognizer.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIGeometry.h>
#import <UIKit/UIPanGestureRecognizer.h>

@interface UIScreenEdgePanGestureRecognizer : UIPanGestureRecognizer
@property (readwrite, nonatomic, assign) UIRectEdge edges;
@end
