//
//  UIPopoverController+UIPrivate.h
//  UIKit
//
//  Created by TaoZeyu on 15/7/24.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPopoverController.h"

@interface UIPopoverController (UIPrivate)

- (id<UIPopoverControllerDelegate>)_delegateNotNil;

@end