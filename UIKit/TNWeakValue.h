//
//  TNWeakValue.h
//  UIKit
//
//  Created by TaoZeyu on 15/11/24.
//  Copyright © 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNWeakValue : NSObject

@property (nonatomic, weak) id value;

+ (instancetype)valueWithWeakObject:(id)value;

@end
