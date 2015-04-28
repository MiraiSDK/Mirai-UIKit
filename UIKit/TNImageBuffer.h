//
//  TNImageBuffer.h
//  UIKit
//
//  Created by TaoZeyu on 15/4/28.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage.h"

@interface TNImageBuffer : NSObject

+ (UIImage *)drawImageAndBufferedItWithClass:(Class)clazz withKey:(NSString *)key withDrawAction:(UIImage *(^)(void))action;

@end
