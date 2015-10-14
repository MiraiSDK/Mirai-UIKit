//
//  TNScreenHelper.h
//  UIKit
//
//  Created by TaoZeyu on 15/10/14.
//  Copyright © 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIScreen;

@interface TNScreenHelper : NSObject

@property (nonatomic, readonly) float density;

- (instancetype)initWithScreen:(UIScreen *)screen;
- (float)inchFromPoint:(float)point;
- (float)pointFromInch:(float)inch;

@end
