//
//  UIAppearance.h
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#define UI_APPEARANCE_SELECTOR
@protocol UIAppearanceContainer <NSObject> @end

@protocol UIAppearance <NSObject>
+ (instancetype)appearance;
+ (instancetype)appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass, ... NS_REQUIRES_NIL_TERMINATION;

@end




