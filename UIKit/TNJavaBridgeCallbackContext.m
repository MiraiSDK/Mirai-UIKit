//
//  TNJavaBridgeCallbackContext.m
//  UIKit
//
//  Created by TaoZeyu on 15/7/1.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNJavaBridgeCallbackContext+UIPrivate.h"

typedef struct JavaTypeStruct {
    jclass typeClass;
    jmethodID valueOfMethod;
    jmethodID valueMethod;
} JavaTypeStruct;

JavaTypeStruct JavaTypeStructMake(const char *typeClassName,
                                  const char *valueOfMethodName, const char *valueOfMethodParamsName,
                                  const char *valueMethodName, const char *valueMethodParamsName) {
    
    JavaTypeStruct jts;
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    
    jts.typeClass = (*env)->FindClass(env, typeClassName);
    jts.valueOfMethod = (*env)->GetMethodID(env, jts.typeClass, valueOfMethodName, valueOfMethodParamsName);
    jts.valueMethod = (*env)->GetMethodID(env, jts.typeClass, valueMethodName, valueMethodParamsName);
    
    return jts;
}

@implementation TNJavaBridgeCallbackContext
{
    jarray _jArgs;
    BOOL _invaild;
}
static JavaTypeStruct _integerTypeStruct;
static JavaTypeStruct _floatTypeStruct;
static JavaTypeStruct _doubleTypeStruct;
static JavaTypeStruct _stringTypeStruct;

+ (void)initialize
{
    _integerTypeStruct = JavaTypeStructMake(
        "java/lang/Integer",
        "valueOf", "(I)Ljava/lang/Integer;",
        "intValue", "()I"
    );
    _floatTypeStruct = JavaTypeStructMake(
        "java/lang/Float",
        "valueOf", "(F)Ljava/lang/Float;",
        "floatValue", "()F"
    );
    _doubleTypeStruct = JavaTypeStructMake(
        "java/lang/Double",
        "valueOf", "(D)Ljava/lang/Double;",
        "doubleValue", "()D"
    );
    _stringTypeStruct = JavaTypeStructMake(
        "java/lang/String",
        "valueOf", "(Ljava/lang/Object;)Ljava/lang/String;",
        "toString", "()Ljava/lang/String;"
    );
}

- (instancetype)initWithArgs:(jarray)args
{
    if (self = [super init]) {
        JNIEnv *env = [[TNJavaHelper sharedHelper] env];
        _jArgs = (*env)->NewGlobalRef(env, args);
    }
    return self;
}

- (void)dealloc
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    (*env)->DeleteGlobalRef(env, _jArgs);
}

- (void)setInvalid
{
    _invaild = YES;
}

@end
