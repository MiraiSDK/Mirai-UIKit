//
//  UIAndroidEventsServer.h
//  UIKit
//
//  Created by Chen Yonghui on 11/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIEvent+Android.h"

@interface UIAndroidEventsServer : NSObject

+ (UIEvent *)event;
@end
