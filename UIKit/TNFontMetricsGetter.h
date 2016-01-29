//
//  TNFontMetricsGetter.h
//  UIKit
//
//  Created by TaoZeyu on 16/1/28.
//  Copyright © 2016年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNFontMetricsGetter : NSObject

+ (NSDictionary *)fontMetricsWithFontFamilyName:(NSString *)fontFamilyName withSize:(NSNumber *)sizeNumber;
+ (NSDictionary *)fontMetricsWithFontFamilyName:(NSString *)fontFamilyName
                                       withSize:(NSNumber *)sizeNumber
                                       withBold:(NSNumber *)boldNumber withItalic:(NSNumber *)italicNumber;

@end
