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
    jts.valueOfMethod = (*env)->GetStaticMethodID(env, jts.typeClass, valueOfMethodName, valueOfMethodParamsName);
    jts.valueMethod = (*env)->GetMethodID(env, jts.typeClass, valueMethodName, valueMethodParamsName);
    
    return jts;
}

@implementation TNJavaBridgeCallbackContext
{
    jarray _jArgs;
    jobject _jReturnObject;
    
    BOOL _invaild;
}
static JavaTypeStruct _integerTypeStruct;
static JavaTypeStruct _floatTypeStruct;
static JavaTypeStruct _doubleTypeStruct;
static JavaTypeStruct _boolTypeStruct;
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
    _boolTypeStruct = JavaTypeStructMake(
        "java/lang/Boolean",
        "valueOf", "(Z)Ljava/lang/Boolean;",
        "booleanValue", "()Z"
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
    
    if (_jReturnObject != NULL) {
        (*env)->DeleteGlobalRef(env, _jReturnObject);
    }
    (*env)->DeleteGlobalRef(env, _jArgs);
}

- (NSUInteger)parameterCount
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jint jarrayLength = (*env)->GetArrayLength(env, _jArgs);
    return (NSUInteger)jarrayLength;
}

- (void)setInvalid
{
    _invaild = YES;
}

- (jobject)jReturnObject
{
    return _jReturnObject;
}

- (void)setJReturnObject:(jobject)jReturnObject
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    
    if (jReturnObject != NULL) {
        (*env)->NewGlobalRef(env, jReturnObject);
    }
    if (_jReturnObject != NULL) {
        (*env)->DeleteGlobalRef(env, _jReturnObject);
    }
    _jReturnObject = jReturnObject;
}

- (BOOL)isIntegerParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    return (*env)->IsInstanceOf(env, value, _integerTypeStruct.typeClass);
}

- (BOOL)isFloatParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    return (*env)->IsInstanceOf(env, value, _floatTypeStruct.typeClass);
}

- (BOOL)isDoubleParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    return (*env)->IsInstanceOf(env, value, _doubleTypeStruct.typeClass);
}

- (BOOL)isBoolParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    return (*env)->IsInstanceOf(env, value, _boolTypeStruct.typeClass);
}

- (BOOL)isStringParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    return (*env)->IsInstanceOf(env, value, _stringTypeStruct.typeClass);
}

- (int)integerParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    if (value == NULL) {
        return 0;
    }
    return (*env)->CallIntMethod(env, value, _integerTypeStruct.valueMethod);
}

- (float)floatParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    if (value == NULL) {
        return 0.0;
    }
    return (*env)->CallFloatMethod(env, value, _floatTypeStruct.valueMethod);
}

- (double)doubleParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    if (value == NULL) {
        return 0.0;
    }
    return (*env)->CallDoubleMethod(env, value, _doubleTypeStruct.valueMethod);
}

- (BOOL)boolParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    if (value == NULL) {
        return 0.0;
    }
    return (*env)->CallDoubleMethod(env, value, _boolTypeStruct.valueMethod);
}

- (NSString *)stringParameterAt:(NSUInteger)index
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->GetObjectArrayElement(env, _jArgs, (jsize)index);
    if (value == NULL) {
        return nil;
    }
    const char *str = (*env)->GetStringUTFChars(env, value, 0);
    return [[NSString alloc] initWithCString:str];
}

- (void)setIntegerResult:(int)result
{
    if (_invaild) {
        [self _printInvailedMessage];
        return;
    }
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->CallStaticObjectMethod(env, _integerTypeStruct.typeClass,
                                                   _integerTypeStruct.valueOfMethod, result);
    [self setJReturnObject:value];
}

- (void)setFloatResult:(float)result
{
    if (_invaild) {
        [self _printInvailedMessage];
        return;
    }
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->CallStaticObjectMethod(env, _floatTypeStruct.typeClass,
                                                   _floatTypeStruct.valueOfMethod, result);
    [self setJReturnObject:value];
}

- (void)setDoubleResult:(double)result
{
    if (_invaild) {
        [self _printInvailedMessage];
        return;
    }
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->CallStaticObjectMethod(env, _doubleTypeStruct.typeClass,
                                                   _doubleTypeStruct.valueOfMethod, result);
    [self setJReturnObject:value];
}

- (void)setBoolResult:(BOOL)result
{
    if (_invaild) {
        [self _printInvailedMessage];
        return;
    }
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->CallStaticObjectMethod(env, _boolTypeStruct.typeClass,
                                                   _boolTypeStruct.valueOfMethod, result);
    [self setJReturnObject:value];
}

- (void)setStringResult:(NSString *)result
{
    if (_invaild) {
        [self _printInvailedMessage];
        return;
    }
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject value = (*env)->NewStringUTF(env, result.cString);
    [self setJReturnObject:value];
}

- (void)_printInvailedMessage
{
    NSLog(@"warning: TNJavaBridgeCallbackContext has invalid. the result value you puted will be not return to Java.");
}

@end
