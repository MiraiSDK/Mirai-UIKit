//
//  UIBarItem.h
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGeometry.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIAppearance.h>
#import <UIKit/UIControl.h>

@class UIImage;

@interface UIBarItem : NSObject <UIAppearance>
@property(nonatomic,getter=isEnabled) BOOL         enabled;
@property(nonatomic,copy)             NSString    *title;
@property(nonatomic,retain)           UIImage     *image;
@property(nonatomic,retain)           UIImage     *landscapeImagePhone;
@property(nonatomic)                  UIEdgeInsets imageInsets;
@property(nonatomic)                  UIEdgeInsets landscapeImagePhoneInsets;
@property(nonatomic)                  NSInteger    tag;
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state;
- (NSDictionary *)titleTextAttributesForState:(UIControlState)state;

@end
