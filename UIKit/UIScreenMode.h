//
//  UIScreenMode.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <CoreGraphics/CoreGraphics.h>

@interface UIScreenMode : NSObject
@property(readonly,nonatomic) CGSize  size;             // The width and height in pixels
@property(readonly,nonatomic) CGFloat pixelAspectRatio; // The aspect ratio of a single pixel. The ratio is defined as X/Y.

@end
