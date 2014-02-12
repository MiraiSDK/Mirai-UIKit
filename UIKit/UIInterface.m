//
//  UIInterface.m
//  UIKit
//
//  Created by Chen Yonghui on 2/12/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIInterface.h"

@implementation UIColor (UIColorSystemColors)
+ (UIColor *)lightTextColor
{
    return [UIColor colorWithWhite:1.0f alpha:0.6f];
}
+ (UIColor *)darkTextColor
{
    return [UIColor colorWithWhite:0.0f alpha:1.0f];
}

+ (UIColor *)groupTableViewBackgroundColor
{
    return [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
}

+ (UIColor *)viewFlipsideBackgroundColor
{
    return [UIColor colorWithRed:31.0f/255.0f green:33.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
}
+ (UIColor *)scrollViewTexturedBackgroundColor
{
    return [UIColor colorWithRed:111.0f/255.0f green:113.0f/255.0f blue:121.0f/255.0f alpha:1.0f];
}
+ (UIColor *)underPageBackgroundColor
{
    return [UIColor colorWithRed:181.0f/255.0f green:183.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
}

@end

@implementation UIFont (UIFontSystemFonts)
+ (CGFloat)labelFontSize
{
    return 17.0f;
}

+ (CGFloat)buttonFontSize
{
    return 18.0f;
}

+ (CGFloat)smallSystemFontSize
{
    return 12.0f;
}
+ (CGFloat)systemFontSize
{
    return 14.0f;
}

@end
