//
//  BKRenderingService.h
//  UIKit
//
//  Created by Chen Yonghui on 6/17/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
struct android_app;

@interface BKRenderingService : NSObject

@end

void BKRenderingServiceBegin(struct android_app *androidApp);
void BKRenderingServiceEnd();
CGRect BKRenderingServiceGetPixelBounds();
