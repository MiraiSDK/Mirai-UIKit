//
//  UIStoryboard.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

@interface UIStoryboard : NSObject
+ (UIStoryboard *)storyboardWithName:(NSString *)name bundle:(NSBundle *)storyboardBundleOrNil;

- (id)instantiateInitialViewController;
- (id)instantiateViewControllerWithIdentifier:(NSString *)identifier;

@end
