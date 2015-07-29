//
//  UIResponder+UIPrivate.h
//  UIKit
//
//  Created by TaoZeyu on 15/7/24.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIResponder.h"
#import "UIWindow.h"

@interface UIResponder (UIPrivate)

- (UIWindow *)_responderWindow;

@end