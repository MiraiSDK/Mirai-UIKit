//
//  NSText.m
//  UIKit
//
//  Created by Chen Yonghui on 12/8/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "NSText.h"

CTTextAlignment NSTextAlignmentToCTTextAlignment(NSTextAlignment nsTextAlignment)
{
    CTTextAlignment ctAlignment = kCTTextAlignmentLeft;
    
    switch (nsTextAlignment) {
        case NSTextAlignmentLeft:
            ctAlignment = kCTTextAlignmentLeft;
            break;
        case NSTextAlignmentCenter:
            ctAlignment = kCTTextAlignmentCenter;
            break;
        case NSTextAlignmentRight:
            ctAlignment = kCTTextAlignmentRight;
            break;
        case NSTextAlignmentJustified:
            ctAlignment = kCTTextAlignmentJustified;
            break;
        case NSTextAlignmentNatural:
            ctAlignment = kCTTextAlignmentNatural;
            break;
            
        default:
            break;
    }
    return ctAlignment;
}

NSTextAlignment NSTextAlignmentFromCTTextAlignment(CTTextAlignment ctTextAlignment)
{
    NSTextAlignment nsAlignment = NSTextAlignmentLeft;
    switch (ctTextAlignment) {
        case kCTTextAlignmentLeft:nsAlignment = NSTextAlignmentLeft;break;
        case kCTTextAlignmentCenter:nsAlignment = NSTextAlignmentCenter;break;
        case kCTTextAlignmentRight:nsAlignment = NSTextAlignmentRight;break;
        case kCTTextAlignmentJustified:nsAlignment = NSTextAlignmentJustified;break;
        case kCTTextAlignmentNatural:nsAlignment = NSTextAlignmentNatural;break;

        default:
            break;
    }
    
    return nsAlignment;
}
