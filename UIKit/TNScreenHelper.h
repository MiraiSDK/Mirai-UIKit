//
//  TNScreenHelper.h
//  UIKit
//
//  Created by TaoZeyu on 15/10/14.
//  Copyright © 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

@class UIScreen;
@class UIView;

@interface TNScreenHelper : NSObject

UIKIT_EXTERN TNScreenHelper *TNScreenHelperOfView(UIView *view);

@property (nonatomic, readonly) float density;

- (instancetype)initWithScreen:(UIScreen *)screen;
- (float)inchFromPoint:(float)point;
- (float)pointFromInch:(float)inch;

@end
