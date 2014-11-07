//
//  UIStoryboardSegue.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIStoryboardSegue.h"

@implementation UIStoryboardSegue
+ (instancetype)segueWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination performHandler:(void (^)(void))performHandler
{
    return nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)perform
{
    
}

@end
