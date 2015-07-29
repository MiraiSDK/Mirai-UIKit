//
//  TNViewIneritedPrinter.h
//  UIKitDemo
//
//  Created by TaoZeyu on 15/7/7.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static const NSString *(^TNViewIneritedPrinterOnlyPrintViewType) (UIView *) = ^NSString *(UIView *view) {
    return [NSString stringWithFormat:@"%@", view.class];
};

static const NSString *(^TNViewIneritedPrinterPrintViewAllMessage) (UIView *) = ^NSString *(UIView *view) {
    return [NSString stringWithFormat:@"%@", view];
};

static const NSString *(^TNViewIneritedPrinterViewTypeAndFrame) (UIView *) = ^NSString *(UIView *view) {
    return [NSString stringWithFormat:@"%@%@", view.class, NSStringFromCGRect(view.frame)];
};

@interface TNViewIneritedPrinter : NSObject

+ (UIView *) rootOf:(UIView *)view;
+ (void)logToRootSuperviewFrom:(UIView *)startView handle:(NSString *(^)(UIView *view)) handleBlock;
+ (void)logAllChildWithRoot:(UIView *)rootView handle:(NSString *(^)(UIView *view)) handleBlock;

@end
