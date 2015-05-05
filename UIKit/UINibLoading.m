//
//  UINibLoading.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UINibLoading.h"

NSString * const UINibExternalObjects = @"UINibExternalObjects";

@implementation NSBundle (UINibLoadingAdditions)
- (NSArray *)loadNibNamed:(NSString *)name owner:(id)owner options:(NSDictionary *)options
{
    return @[];
}
@end

@implementation NSObject (UINibLoadingAdditions)

- (void)awakeFromNib
{
    
}

- (void)prepareForInterfaceBuilder
{
    
}
@end

NSString * const UINibProxiedObjectsKey = @"UINibProxiedObjectsKey";
