//
//  UIViewController+Private.h
//  UIKit
//
//  Created by Chen Yonghui on 12/30/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#ifndef UIKit_UIViewController_Private_h
#define UIKit_UIViewController_Private_h

#import "UIViewController.h"

@interface UIViewController (Private)
+ (void)_performMemoryWarning;
- (void)_setParentViewController:(UIViewController *)parentController;
@end
#endif
