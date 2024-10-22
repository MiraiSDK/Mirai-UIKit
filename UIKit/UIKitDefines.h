//
//  UIKitDefines.h
//  UIKit
//
//  Created by Chen Yonghui on 12/6/13.
//  Copyright (c) 2013 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Availability.h>

#ifdef __cplusplus
#define UIKIT_EXTERN		extern "C" __attribute__((visibility ("default")))
#else
#define UIKIT_EXTERN	        extern __attribute__((visibility ("default")))
#endif

#define UIKIT_STATIC_INLINE	static inline

#define NS_UNIMPLEMENTED_LOG NSLog(@"Unimplemented method: %s",__PRETTY_FUNCTION__)

#ifndef NS_REQUIRES_NIL_TERMINATION
#define NS_REQUIRES_NIL_TERMINATION __attribute__((sentinel(0,1)))
#endif

