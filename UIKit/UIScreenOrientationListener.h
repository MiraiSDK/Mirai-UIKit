//
//  UIScreenOrientationListener.h
//  UIKit
//
//  Created by TaoZeyu on 15/8/5.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScreenOrientationListener : NSObject

+ (void)updateAndroidOrientation:(NSUInteger)supportedInterfaceOrientations;
+ (BOOL)isLandscaped;

@end
