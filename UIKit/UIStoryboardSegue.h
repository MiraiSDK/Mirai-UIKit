//
//  UIStoryboardSegue.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

@class UIViewController;

@interface UIStoryboardSegue : NSObject
+ (instancetype)segueWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination performHandler:(void (^)(void))performHandler;

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination; // Designated initializer

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) id sourceViewController;
@property (nonatomic, readonly) id destinationViewController;

- (void)perform;

@end
