//
//  TNViewIneritedPrinter.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/7/7.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNViewIneritedPrinter.h"

@implementation TNViewIneritedPrinter

//+ (void)load
//{
//    TNViewIneritedPrinterOnlyPrintViewType = ^NSString *(UIView *view) {
//        return [NSString stringWithFormat:@"%@", view.class];
//    };
//    TNViewIneritedPrinterPrintViewAllMessage = ^NSString *(UIView *view) {
//        return [NSString stringWithFormat:@"%@", view];
//    };
//    
//    NSLog(@"%@ \n %@", TNViewIneritedPrinterOnlyPrintViewType, TNViewIneritedPrinterOnlyPrintViewType);
//}

+ (UIView *)rootOf:(UIView *)view
{
    while (view.superview) {
        view = view.superview;
    }
    return view;
}

+ (void)logToRootSuperviewFrom:(UIView *)startView handle:(NSString *(^)(UIView *))handleBlock
{
    NSLog(@"※ %@", handleBlock(startView));
    
    UIView *view = startView.superview;
    while (view) {
        NSLog(@"  ├ %@", handleBlock(view));
        view = view.superview;
    }
    NSLog(@" ");
}

+ (void)logAllChildWithRoot:(UIView *)rootView handle:(NSString *(^)(UIView *))handleBlock
{
    NSLog(@"※ %@", handleBlock(rootView));
    for (UIView *childView in rootView.subviews) {
        [self _logAllChildrenWithPrefix:@": ├ " withRoot:childView handle:handleBlock];
    }
    NSLog(@" ");
}

+ (void)_logAllChildrenWithPrefix:(NSString *)prefix
                         withRoot:(UIView *)rootView handle:(NSString *(^)(UIView *))handleBlock
{
    NSString *format = [prefix stringByAppendingString:@"%@"];
    NSLog(format, handleBlock(rootView));
    
    NSString *childPrefix = [@": " stringByAppendingString:prefix];
    
    for (UIView *childView in rootView.subviews) {
        [self _logAllChildrenWithPrefix:childPrefix withRoot:childView handle:handleBlock];
    }
}

@end