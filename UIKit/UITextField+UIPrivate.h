//
//  UITextField+UIPrivate.h
//  UIKit
//
//  Created by TaoZeyu on 15/7/3.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITextField.h"
#import "TNJavaBridgeProxy.h"

@interface UITextField (UIPrivate)

- (void)setTextWatcherListener:(TNJavaBridgeProxy *)textWatcherListener;
- (void)setOnFocusChangeListener:(TNJavaBridgeProxy *)focusChangeLisenter;

@end