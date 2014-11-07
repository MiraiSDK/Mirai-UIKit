//
//  UIStoryboardPopoverSegue.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIStoryboardSegue.h>

@class UIPopoverController;

@interface UIStoryboardPopoverSegue : UIStoryboardSegue
@property (nonatomic, retain, readonly) UIPopoverController *popoverController;

@end
