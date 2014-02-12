//
//  UIBarItem.m
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIBarItem.h"

@implementation UIBarItem
- (id)init
{
    self = [super init];
    if (self) {
        _enabled = YES;
        _imageInsets = UIEdgeInsetsZero;
        _landscapeImagePhoneInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state
{
    NS_UNIMPLEMENTED_LOG;
}

- (NSDictionary *)titleTextAttributesForState:(UIControlState)state
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

+ (instancetype)appearance
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}

+ (instancetype)appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass, ...
{
    NS_UNIMPLEMENTED_LOG;
    return nil;
}
@end
