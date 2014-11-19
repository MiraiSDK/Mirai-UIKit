//
//  TNJavaHelper.m
//  TNJavaHelper
//
//  Created by Chen Yonghui on 7/25/14.
//  Copyright (c) 2014 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNJavaHelper.h"

NSString *TNJavaEnvKey = @"TNJavaEnvKey";

@implementation TNJavaHelper {
    JavaVM *vm;
    jclass clazz;
    
    jobject _clsLoader;
    jmethodID _findClass;
}

+ (void)initializeWithVM:(JavaVM *)vm activityClass:(jclass)clazz
{
    TNJavaHelper *helper = [self sharedHelper];
    
    // attach current thread to java vm, so we can call java code
    helper->vm = vm;
    
    
    JNIEnv *env = [helper env];
    helper->clazz = (*env)->NewGlobalRef(env,clazz);

    //
    //
    
    NSLog(@"will find class:android/app/NativeActivity");
    jclass activityClass = (*env)->FindClass(env,"android/app/NativeActivity");
    if (activityClass == NULL) {
        NSLog(@"find class android/app/NativeActivity failed");
        
    }
    
    NSLog(@"will get method getClassLoader");
    jmethodID getClassLoader = (*env)->GetMethodID(env, activityClass,"getClassLoader", "()Ljava/lang/ClassLoader;");
    if (getClassLoader == NULL) {
        NSLog(@"get method:getClassLoader failed ");
    }
    
    NSLog(@"will call getClassLoader");
    jobject clsLoader = (*env)->CallObjectMethod(env, clazz, getClassLoader);
    NSLog(@"done getClassLoader, result:%p",clsLoader);
    helper->_clsLoader = (*env)->NewGlobalRef(env,clsLoader);
    
    
    NSLog(@"will find class java/lang/ClassLoader");
    jclass classLoader = (*env)->FindClass(env, "java/lang/ClassLoader");
    
    jmethodID findClass = (*env)->GetMethodID(env, classLoader, "loadClass", "(Ljava/lang/String;)Ljava/lang/Class;");
    
    helper->_findClass = findClass;
}

- (JNIEnv *)env
{
    NSMutableDictionary *threadDictionary =[[NSThread currentThread] threadDictionary];
    NSValue *value = threadDictionary[TNJavaEnvKey];
    JNIEnv *e = [value pointerValue];
    if (e  == NULL) {
        (*vm)->AttachCurrentThread(vm,&e,NULL);
        value = [NSValue valueWithPointer:e];
        threadDictionary[TNJavaEnvKey] = value;
    }
    return e;
}

- (JavaVM *)vm
{
    return vm;
}

- (jclass)clazz
{
    return clazz;
}

- (jclass)findCustomClass:(NSString *)className
{
    JNIEnv *env = [self env];
    jstring strClassName = (*env)->NewStringUTF(env,className.UTF8String);
    
    jclass classIWant = (jclass)(*env)->CallObjectMethod(env, _clsLoader, _findClass, strClassName);
    
    return classIWant;
}

+ (id)sharedHelper
{
    static dispatch_once_t onceToken;
    static TNJavaHelper *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark -

- (id)callMethod:(NSString *)method class:(NSString *)className
{
    JNIEnv *env = [self env];
    jclass handlerClass = (*env)->FindClass(env, [className UTF8String]);
    if (handlerClass == NULL) {
        NSLog(@"can not find java class:%@",className);
        return nil;
    }
    
    // (argument-types)return-type
    
    NSString *methodSig = @"(Ljava/lang/String;)V";
    
    jmethodID mid = (*env)->GetMethodID(env, handlerClass, method.UTF8String, methodSig.UTF8String);
    if (mid == NULL) {
        NSLog(@"can not find method: %@",method);
        return nil;
    }

    
    jstring argu = NULL;
    (*env)->CallVoidMethod(env,handlerClass,mid,argu);
    
    return nil;
}

- (void)sss
{
    JNIEnv *env = [self env];
    jclass handlerClass = (*env)->FindClass(env, "com/foo/bar/ResultHandler");
    if (handlerClass == NULL) {
        NSLog(@"can not find java class");
    }
    
    jmethodID mid = (*env)->GetMethodID(env, handlerClass, "onReturnedString", "(Ljava/lang/String;)V");
    if (mid == NULL) {
        NSLog(@"can not find method");
    }
    
    jstring argu = NULL;
    (*env)->CallVoidMethod(env,handlerClass,mid,argu);
    
    

}
- (void)call
{
//    jclass thiz = app_state->activity->clazz;
//    
//    jclass test = (*env)->GetObjectClass(env, thiz);
//    
//    jmethodID messageID = (*env)->GetMethodID(env,test,"updateSupportedOrientation","(I)V");
//    
//    NSUInteger supportedInterfaceOrientations = [_app supportedInterfaceOrientations];
//    jint o = [self JAVA_SCREEN_ORIENTATIONForCocoaInterfaceOrientations:supportedInterfaceOrientations];
//    
//    (*env)->CallVoidMethod(env,thiz,messageID,o);
//    
//    (*env)->DeleteLocalRef(env,test);

}
@end
