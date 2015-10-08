//
//  TNCancelGeneratorGestureRecognizer.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/10/8.
//  Copyright © 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNCancelGeneratorGestureRecognizer : UIGestureRecognizer

@property (nonatomic, strong) UIGestureRecognizer *proxyGestureRecognizer;

@end
