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
@class CALayer;

@interface BKRenderingService : NSObject

@end

void BKRenderingServiceBegin(struct android_app *androidApp);
void BKRenderingServiceRun();
void BKRenderingSetShouldRefreshScreen(BOOL value);
void BKRenderingServiceEnd();
CGRect BKRenderingServiceGetPixelBounds();
void BKRenderingServiceUploadRenderLayer(CALayer *layer);
NSLock *BKLayerDisplayLock();
