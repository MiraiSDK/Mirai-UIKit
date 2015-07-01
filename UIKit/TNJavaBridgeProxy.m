//
//  TNJavaBridgeProxy.m
//  UIKit
//
//  Created by TaoZeyu on 15/6/30.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "TNJavaBridgeProxy.h"
#import "TNJavaBridgeCallbackContext+UIPrivate.h"
#import <TNJavaHelper/TNJavaHelper.h>

@implementation TNJavaBridgeProxy
{
    jint _proxyId;
    jobject _jProxy;
    jobject _jProxiedInstance;
    
    NSMutableArray *_callbackList;
}
static jmethodID _getProxiedInstanceMethod;

static NSObject *_objLock;
static NSMutableDictionary *_id2ProxyMap;
static jint _nextProxyId;

+ (void)initialize
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    
    jclass class = [[TNJavaHelper sharedHelper] findCustomClass:@"org.tiny4.JavaBridgeTools.JavaBridgeProxy"];
    jmethodID methodId = (*env)->GetMethodID(env, class, "getProxiedInstance", "()Ljava/lang/Object;");
    
    _getProxiedInstanceMethod = (*env)->NewGlobalRef(env, methodId);
    
    _objLock = [[NSObject alloc] init];
    _id2ProxyMap = [[NSMutableDictionary alloc] init];
    _nextProxyId = 0;
}

- (instancetype)initWithDefinition:(TNJavaBridgeDefinition *)definition
                      withCallback:(void (^)(TNJavaBridgeCallbackContext *))callback
{
    if (self = [self initWithDefinition:definition]) {
        [self callback:callback];
    }
    return self;
}

- (instancetype)initWithDefinition:(TNJavaBridgeDefinition *)definition
{
    if (self = [super init]) {
        @synchronized(_objLock) {
            _proxyId = [TNJavaBridgeProxy _newProxyId];
            [TNJavaBridgeProxy _registerProxy:self asId:_proxyId];
            _jProxy = [definition newJProxyWithId:_proxyId];
            _jProxiedInstance = [self _proxiedInstanceFromProxy:_jProxy];
        }
        _callbackList = [self _newAllNilArrayWithCount:definition.methodsCount];
    }
    return self;
}

- (void)dealloc
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    
    (*env)->DeleteGlobalRef(env, _jProxy);
    (*env)->DeleteGlobalRef(env, _jProxiedInstance);
    
    @synchronized(_objLock) {
        [TNJavaBridgeProxy _unregisterProxy:self];
    }
}

jobject Java_org_tiny4_JavaBridgeTools_JavaBridgeProxy_navtiveCallback(JNIEnv *env, jobject obj,
                                                                  jint instanceId, jint methodId, jarray args) {
    
    TNJavaBridgeProxy *proxy;
    @synchronized(_objLock) {
        proxy = [TNJavaBridgeProxy _findProxyWithId:instanceId];
    }
    
    if (!proxy) {
        NSLog(@"warning: navetiveCallback not found TNJavaBridgeProxy instance whoses id equals %i. you should unregsiter Java listener before release Objective-C TNJavaBridgeProxy instance, otherwise, Java listener would not find any callback block on Objective-C and may make some very serious error.", instanceId);
        return NULL;
    }
    void (^callback)(TNJavaBridgeCallbackContext *);
    
    callback = [proxy->_callbackList objectAtIndex:((NSUInteger)methodId)];
    if ([[NSNull null] isEqual:callback]) {
        return NULL;
    }
    
    TNJavaBridgeCallbackContext *context = [[TNJavaBridgeCallbackContext alloc] initWithArgs:args];
    callback(context);
    [context setInvalid];
    
    return context.jReturnObject;
}

- (jobject)jProxiedInstance
{
    return _jProxiedInstance;
}

- (void)target:(id)target action:(SEL)action
{
    [self methodIndex:0 target:target action:action];
}

- (void)callback:(void (^)(TNJavaBridgeCallbackContext *))callback
{
    [self methodIndex:0 callback:callback];
}

- (void)methodIndex:(NSUInteger)methodIndex target:(id)target action:(SEL)action
{
    __unsafe_unretained id unsafeTarget = target;
    
    [self methodIndex:methodIndex callback:^(TNJavaBridgeCallbackContext *context) {
        if (![unsafeTarget respondsToSelector:action]) {
            NSLog(@"warning: target %@ can't responds to %@ on JavaBridgeProxy.",
                  target, NSStringFromSelector(action));
            return;
        }
        [unsafeTarget performSelector:action withObject:self];
    }];
}

- (void)methodIndex:(NSUInteger)methodIndex callback:(void (^)(TNJavaBridgeCallbackContext *))callback
{
    @synchronized(self) {
        [_callbackList replaceObjectAtIndex:methodIndex withObject:callback];
    }
}

- (void)unbindAllCallback
{
    @synchronized(self) {
        for (NSUInteger i=0; i<_callbackList.count; i++) {
            [_callbackList replaceObjectAtIndex:i withObject:[NSNull null]];
        }
    }
}

- (void)unbindCallbackWithMethodIndex:(NSUInteger)methodIndex
{
    @synchronized(self) {
        [_callbackList replaceObjectAtIndex:methodIndex withObject:[NSNull null]];
    }
}

+ (jint)_newProxyId
{
    // _nextProxyId may be over the maximum value of jint and close to zero from negative-axis.
    // so, we have to consider avoiding duplicate id.
    while ([self _findProxyWithId:_nextProxyId]) {
        _nextProxyId++;
    }
    jint resultId = _nextProxyId;
    _nextProxyId++;
    return resultId;
}

- (jobject)_proxiedInstanceFromProxy:(jobject)jProxy
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    return (*env)->CallObjectMethod(env, jProxy, _getProxiedInstanceMethod);
}

+ (TNJavaBridgeProxy *)_findProxyWithId:(jint)proxyId
{
    return [_id2ProxyMap valueForKey:[[NSString alloc] initWithFormat:@"%i", proxyId]];
}

+ (void)_registerProxy:(TNJavaBridgeProxy *)proxy asId:(jint)proxyId
{
    [_id2ProxyMap setValue:proxy forKey:[[NSString alloc] initWithFormat:@"%i", proxyId]];
}

+ (void)_unregisterProxy:(TNJavaBridgeProxy *)proxy
{
    [_id2ProxyMap removeObjectForKey:[[NSString alloc] initWithFormat:@"%i", proxy->_proxyId]];
}

- (NSMutableArray *)_newAllNilArrayWithCount:(NSUInteger)count
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSUInteger i=0; i<count; i++) {
        [array addObject:[NSNull null]];
    }
    return array;
}

@end
