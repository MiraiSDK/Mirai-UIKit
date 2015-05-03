//
//  TNImageBuffer.m
//  UIKit
//
//  Created by TaoZeyu on 15/4/28.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNImageBuffer.h"

static NSMutableDictionary *_imageBufferedContainer;

@implementation TNImageBuffer

+ (void)initialize
{
    _imageBufferedContainer = [[NSMutableDictionary alloc] init];
}

+ (UIImage *)drawImageAndBufferedItWithClass:(Class)clazz withKey:(NSString *)childKey withDrawAction:(UIImage *(^)(void))action
{
    @synchronized (self) {
        
    }
    NSString *key = [NSString stringWithFormat:@"%@-%@", clazz, childKey];
    UIImage *image = [_imageBufferedContainer objectForKey:key];
    if (image == nil) {
        image = action();
        [_imageBufferedContainer setObject:image forKey:key];
    }
    return image;
}

@end
