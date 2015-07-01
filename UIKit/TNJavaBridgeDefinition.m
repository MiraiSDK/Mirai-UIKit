//
//  TNJavaBridgeDefinition.m
//  UIKit
//
//  Created by TaoZeyu on 15/6/30.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNJavaBridgeDefinition.h"
#import <TNJavaHelper/TNJavaHelper.h>

@interface TNJavaBridgeDefinition ()

@property (nonatomic) NSUInteger classesCount;
@property (nonatomic) NSUInteger methodsCount;

@end

@implementation TNJavaBridgeDefinition
{
    jclass _jFactoryClass;
    jmethodID _jCreateJavaBridgeProxyMethod;
    jobject _jProxyFactory;
}

- (instancetype)initWithProxiedClassName:(NSString *)proxiedClassName
                    withMethodSignatures:(NSArray *)methodSignatures
{
    return [self initWithProxiedClassNames:@[proxiedClassName] withMethodSignatures:methodSignatures];
}

- (instancetype)initWithProxiedClassName:(NSString *)proxiedClassName
                     withMethodSignature:(NSString *)methodSignature
{
    return [self initWithProxiedClassNames:@[proxiedClassName] withMethodSignatures:@[methodSignature]];
}

- (instancetype)initWithProxiedClassNames:(NSArray *)proxiedClassNames
                     withMethodSignatures:(NSArray *)methodSignatures
{
    if (self = [super init]) {
        
        _classesCount = proxiedClassNames.count;
        _methodsCount = methodSignatures.count;
        
        _jFactoryClass = [self _findFactoryClass];
        if (_jFactoryClass == NULL) {
            return nil;
        }
        
        _jCreateJavaBridgeProxyMethod = [self _findCreateJavaBridgeProxyMethodWithFactoryClass:_jFactoryClass];
        if (_jCreateJavaBridgeProxyMethod == NULL) {
            return nil;
        }
        
        _jProxyFactory = [self _newProxyFactoryWithProxiedClassNames:proxiedClassNames
                                                withMethodSignatures:methodSignatures];
        if (_jProxyFactory == NULL) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    (*env)->DeleteGlobalRef(env, _jFactoryClass);
    (*env)->DeleteGlobalRef(env, _jCreateJavaBridgeProxyMethod);
    (*env)->DeleteGlobalRef(env, _jProxyFactory);
}

- (jobject)newJProxyWithId:(jint)proxyId
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jobject jPorxy = (*env)->CallObjectMethod(env, _jProxyFactory, _jCreateJavaBridgeProxyMethod, proxyId);
    (*env)->NewGlobalRef(env, jPorxy);
    (*env)->DeleteLocalRef(env, jPorxy);
    return jPorxy;
}

- (jclass)_findFactoryClass
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jclass jFactoryClass = [[TNJavaHelper sharedHelper] findCustomClass:@"org.tiny4.JavaBridgeTools.JavaBridgeProxyFactory"];
    
    if (!jFactoryClass) {
        NSLog(@"class not found: %@",@"org.tiny4.JavaBridgeTools.JavaBridgeProxyFactory");
        return NULL;
    }
    (*env)->NewGlobalRef(env, jFactoryClass);
    (*env)->DeleteLocalRef(env, jFactoryClass);
    return jFactoryClass;
}

- (jmethodID)_findCreateJavaBridgeProxyMethodWithFactoryClass:(jclass)factoryClass
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jmethodID jCreateJavaBridgeProxyMethod = (*env)->GetMethodID(env, factoryClass,
                                        "createFactory", "(I)Lorg/tiny4/JavaBridgeTools/JavaBridgeProxy;");
    
    if (jCreateJavaBridgeProxyMethod == NULL) {
        NSLog(@"method id not found:%@",@"createFactory");
        return NULL;
    }
    (*env)->NewGlobalRef(env, jCreateJavaBridgeProxyMethod);
    (*env)->DeleteLocalRef(env, jCreateJavaBridgeProxyMethod);
    return jCreateJavaBridgeProxyMethod;
}

- (jobject)_newProxyFactoryWithProxiedClassNames:(NSArray *)proxiedClassNames
                            withMethodSignatures:(NSArray *)methodSignatures
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jmethodID mid = (*env)->GetMethodID(env, _jFactoryClass,
    "createFactory", "([Ljava/lang/String;[Ljava/lang/String;)Lorg/tiny4/JavaBridgeTools/JavaBridgeProxyFactory;");
    
    if (mid == NULL) {
        NSLog(@"method id not found:%@",@"createFactory");
        return NULL;
    }
    jobjectArray jProxiedClassNames = [self _newJStringArrayFrom:proxiedClassNames env:env];
    jobjectArray jMethodSignatures = [self _newJStringArrayFrom:methodSignatures env:env];
    
    jobject jProxyFactory = (*env)->CallStaticObjectMethod(env, _jFactoryClass, mid,
                                                           jProxiedClassNames, jMethodSignatures);
    
    (*env)->DeleteLocalRef(env, jProxiedClassNames);
    (*env)->DeleteLocalRef(env, jMethodSignatures);
    
    if (jProxyFactory == NULL) {
        [self _showProxyFactoryResultCodeWithEnv:env];
        return NULL;
    }
    (*env)->NewGlobalRef(env, jProxyFactory);
    (*env)->DeleteLocalRef(env, jProxyFactory);
    return jProxyFactory;
}

- (void)_showProxyFactoryResultCodeWithEnv:(JNIEnv *)env
{
    jmethodID mid = (*env)->GetMethodID(env, _jFactoryClass, "getResultCode","()I");
    if (mid == NULL) {
        NSLog(@"method id not found:%@",@"getResultCode");
        return;
    }
    jint resultCode = (*env)->CallStaticIntMethod(env, _jFactoryClass, mid);
    
    (*env)->DeleteLocalRef(env, _jFactoryClass);
    (*env)->DeleteLocalRef(env, mid);
    
    NSString *resultMessage = @"Uknow";
    
    switch (resultCode) {
        case 0:
        resultMessage = @"Success";
        break;
        
        case 1:
        resultMessage = @"ClassNotFoundCode";
        break;
        
        case 2:
        resultMessage = @"NoSuchMethodCode";
        break;
        
        case 3:
        resultMessage = @"SecurityCode";
        break;
        
        case 4:
        resultMessage = @"DuplicatedMethodSignatureCode";
        break;
        
        case 5:
        resultMessage = @"IllegalAccessCode";
        break;
        
        default:
        break;
    }
    NSLog(@"JavaBridge called result code : %@", resultMessage);
}

- (jobjectArray)_newJStringArrayFrom:(NSArray *)objcArray env:(JNIEnv *)env
{
    jclass stringClass = (*env)->FindClass(env, "java/lang/String");
    jstring emptyHoldString = (*env)->NewStringUTF(env, "");
    jobjectArray jStringArray = (*env)->NewObjectArray(env, (jint)objcArray.count, stringClass, emptyHoldString);
    
    for (NSUInteger i=0; i<objcArray.count; ++i) {
        NSString *objcString = [objcArray objectAtIndex:i];
        jstring elementString = (*env)->NewStringUTF(env, objcString.cString);
        (*env)->SetObjectArrayElement(env, jStringArray, (jint)i, elementString);
        (*env)->DeleteLocalRef(env, elementString);
    }
    (*env)->DeleteLocalRef(env, stringClass);
    (*env)->DeleteLocalRef(env, emptyHoldString);
    
    return jStringArray;
}

@end
