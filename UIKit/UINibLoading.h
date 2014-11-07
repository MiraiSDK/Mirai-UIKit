//
//  UINibLoading.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

UIKIT_EXTERN NSString * const UINibExternalObjects;

@interface NSBundle(UINibLoadingAdditions)
- (NSArray *)loadNibNamed:(NSString *)name owner:(id)owner options:(NSDictionary *)options;
@end

@interface NSObject(UINibLoadingAdditions)
- (void)awakeFromNib;
- (void)prepareForInterfaceBuilder;// NS_AVAILABLE_IOS(8_0);
@end

UIKIT_EXTERN NSString * const UINibProxiedObjectsKey;// NS_DEPRECATED_IOS(2_0, 3_0);
