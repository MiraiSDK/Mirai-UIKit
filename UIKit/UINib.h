//
//  UINib.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

@interface UINib : NSObject
+ (UINib *)nibWithNibName:(NSString *)name bundle:(NSBundle *)bundleOrNil;
+ (UINib *)nibWithData:(NSData *)data bundle:(NSBundle *)bundleOrNil;
- (NSArray *)instantiateWithOwner:(id)ownerOrNil options:(NSDictionary *)optionsOrNil;
@end
