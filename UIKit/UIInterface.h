//
//  UIInterface.h
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIColor.h>
#import <UIKit/UIFont.h>

typedef NS_ENUM(NSInteger, UIBarStyle) {
    UIBarStyleDefault          = 0,
    UIBarStyleBlack            = 1,
    
    UIBarStyleBlackOpaque      = 1, // Deprecated. Use UIBarStyleBlack
    UIBarStyleBlackTranslucent = 2, // Deprecated. Use UIBarStyleBlack and set the translucent property to YES
};

@interface UIColor (UIColorSystemColors)
+ (UIColor *)lightTextColor;
+ (UIColor *)darkTextColor;

+ (UIColor *)groupTableViewBackgroundColor;

+ (UIColor *)viewFlipsideBackgroundColor;// NS_DEPRECATED_IOS(2_0, 7_0);
+ (UIColor *)scrollViewTexturedBackgroundColor;// NS_DEPRECATED_IOS(3_2, 7_0);
+ (UIColor *)underPageBackgroundColor;// NS_DEPRECATED_IOS(5_0, 7_0);
@end

@interface UIFont (UIFontSystemFonts)
+ (CGFloat)labelFontSize;
+ (CGFloat)buttonFontSize;
+ (CGFloat)smallSystemFontSize;
+ (CGFloat)systemFontSize;
@end
