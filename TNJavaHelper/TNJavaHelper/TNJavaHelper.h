//
//  TNJavaHelper.h
//  TNJavaHelper
//
//  Created by Chen Yonghui on 7/25/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <jni.h>

@interface TNJavaHelper : NSObject
+ (void)initializeWithVM:(JavaVM *)vm activityClass:(jclass)clazz;
+ (instancetype)sharedHelper;
- (JNIEnv *)env;
- (jclass)findCustomClass:(NSString *)className;
- (JavaVM *)vm;
- (jclass)clazz;

@end
