//
//  TNFontMetricsGetter.m
//  UIKit
//
//  Created by TaoZeyu on 16/1/28.
//  Copyright © 2016年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNFontMetricsGetter.h"
#import <TNJavaHelper/TNJavaHelper.h>
#include <jni.h>

@implementation TNFontMetricsGetter

static jclass _proxyClass;
static jmethodID _proxyConstructor;
static jmethodID _ascentMethodID;
static jmethodID _bottomMethodID;
static jmethodID _descentMethodID;
static jmethodID _leadingMethodID;
static jmethodID _topMethodID;

+ (void)initialize
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    _proxyClass = [[TNJavaHelper sharedHelper] findCustomClass:@"org.tiny4.CoreTextHelper.FontMetricsProxy"];
    _proxyConstructor = (*env)->GetMethodID(env, _proxyClass, "<init>", "(Ljava/lang/String;FZZ)V");
    
    _ascentMethodID = (*env)->GetMethodID(env, _proxyClass, "ascent", "()F");
    _bottomMethodID = (*env)->GetMethodID(env, _proxyClass, "bottom", "()F");
    _descentMethodID = (*env)->GetMethodID(env, _proxyClass, "descent", "()F");
    _leadingMethodID = (*env)->GetMethodID(env, _proxyClass, "leading", "()F");
    _topMethodID = (*env)->GetMethodID(env, _proxyClass, "top", "()F");
}

+ (NSDictionary *)fontMetricsWithFontFamilyName:(NSString *)fontFamilyName withSize:(NSNumber *)sizeNumber
{
    return [self fontMetricsWithFontFamilyName:fontFamilyName withSize:sizeNumber
                                      withBold:@NO withItalic:@NO];
}

+ (NSDictionary *)fontMetricsWithFontFamilyName:(NSString *)fontFamilyName
                                       withSize:(NSNumber *)sizeNumber
                                       withBold:(NSNumber *)boldNumber withItalic:(NSNumber *)italicNumber
{
    CGFloat size = [sizeNumber floatValue];
    BOOL bold = [boldNumber boolValue];
    BOOL italic = [italicNumber boolValue];
    
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jstring jFontFamilyName = (*env)->NewStringUTF(env, [fontFamilyName UTF8String]);
    jfloat jSize = (jfloat)size;
    jboolean jbold = bold? JNI_TRUE: JNI_FALSE;
    jboolean jItalic = italic? JNI_TRUE: JNI_FALSE;
    jobject proxy = (*env)->NewObject(env, _proxyClass, _proxyConstructor,
                                      jFontFamilyName, jSize, jbold, jItalic);
    
    NSMutableDictionary *metricsMap = [NSMutableDictionary dictionary];
    metricsMap[@"ascent"] = @((CGFloat)(*env)->CallFloatMethod(env, proxy, _ascentMethodID));
    metricsMap[@"bottom"] = @((CGFloat)(*env)->CallFloatMethod(env, proxy, _bottomMethodID));
    metricsMap[@"descent"] = @((CGFloat)(*env)->CallFloatMethod(env, proxy, _descentMethodID));
    metricsMap[@"leading"] = @((CGFloat)(*env)->CallFloatMethod(env, proxy, _leadingMethodID));
    metricsMap[@"top"] = @((CGFloat)(*env)->CallFloatMethod(env, proxy, _topMethodID));
    return metricsMap;
}

@end
