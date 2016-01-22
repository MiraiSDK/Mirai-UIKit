//
//  UIScreenOrientationListener.h
//  UIKit
//
//  Created by TaoZeyu on 15/8/5.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIScreenOrientationListener : NSObject

+ (BOOL)isLandscaped;
+ (void)updateAndroidOrientation:(NSUInteger)supportedInterfaceOrientations;
+ (void)setSupportedInterfaceOrientations:(NSUInteger)supportedInterfaceOrientations;

@end
