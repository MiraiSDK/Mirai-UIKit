//
//  UITapGestureRecognizer+UIPrivate.h
//  UIKit
//
//  Created by TaoZeyu on 15/10/1.
//  Copyright © 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITapGestureRecognizer.h"

@interface UITapGestureRecognizer (UIPrivate)

@property (nonatomic, readonly) NSUInteger currentTapCount;
@property (nonatomic, readonly) NSUInteger currentTouchCount;

@end