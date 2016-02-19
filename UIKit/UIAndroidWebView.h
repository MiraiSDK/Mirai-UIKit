//
//  UIAndroidWebView.h
//  UIKit
//
//  Created by Chen Yonghui on 10/18/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TNJavaBridgeProxy;

@interface UIAndroidWebView : UIView
- (void)setListenerBridgeProxy:(TNJavaBridgeProxy *)bridgeProxy;
- (void)setShouldOverrideUrlLoadingValue:(BOOL)shouldOverrideUrlLoading;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

@end
