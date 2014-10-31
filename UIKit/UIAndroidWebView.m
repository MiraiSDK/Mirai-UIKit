//
//  UIAndroidWebView.m
//  UIKit
//
//  Created by Chen Yonghui on 10/18/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIAndroidWebView.h"
#import <TNJavaHelper/TNJavaHelper.h>

#import <GLES2/gl2.h>

#import "UIEvent+Android.h"

typedef BOOL(^EAGLTextureUpdateCallback)(CATransform3D *t);

@interface CAMovieLayer : CALayer

@property (nonatomic, copy) EAGLTextureUpdateCallback updateCallback;
- (BOOL)updateTextureIfNeeds:(CATransform3D *)t;
- (int)textureID;

@end

@implementation UIAndroidWebView
{
    jobject _jWebView;
    jclass _jWebViewClass;
}

+ (Class)layerClass
{
    return [CAMovieLayer class];
}

- (void)destory
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jmethodID mid = (*env)->GetMethodID(env,_jWebViewClass,"onDestory","()V");
    (*env)->CallVoidMethod(env,_jWebView,mid);
}

- (void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    [self destory];
    
    (*env)->DeleteGlobalRef(env,_jWebView);
    (*env)->DeleteGlobalRef(env,_jWebViewClass);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAMovieLayer *layer = self.layer;
        __weak typeof(self) weakSelf = self;
        layer.updateCallback = ^(CATransform3D *t) {
            BOOL result = [weakSelf updaeTextureIfNeeds:t];
            return result;
        };
        [layer displayIfNeeded];
        
        GLuint tex = [layer textureID];
        [self createJavaWebView:tex];
    }
    return self;
}

- (BOOL)updaeTextureIfNeeds:(CATransform3D *)transform
{
//    NSLog(@"%s",__PRETTY_FUNCTION__);
    static JNIEnv *env = NULL;
    if (env == NULL) {
        JavaVM *vm = [[TNJavaHelper sharedHelper] vm];
        (*vm)->AttachCurrentThread(vm,&env,NULL);
    }
    
    jmethodID mid = (*env)->GetMethodID(env,_jWebViewClass,"updateTextureIfNeeds","([F)I");
    if (mid == NULL) {
        NSLog(@"method id not found:%@",@"updateTextureIfNeeds ([F)I");
        return NO;
    }
    
    jfloatArray jMatrix = (*env)->NewFloatArray(env,16);

    jint result = (*env)->CallIntMethod(env, _jWebView, mid,jMatrix);
    
    //convert java matrix to CATransform3D
    jfloat *arr = (*env)->GetFloatArrayElements(env,jMatrix,NULL);
    CATransform3D t = CATransform3DIdentity;
    if (arr != NULL) {
        CATransform3D matrix = {
            arr[0],arr[1],arr[2],arr[3],
            arr[4],arr[5],arr[6],arr[7],
            arr[8],arr[9],arr[10],arr[11],
            arr[12],arr[13],arr[14],arr[15]};
        t = matrix;
    }
    
    (*env)->ReleaseFloatArrayElements(env,jMatrix,arr,0);
    (*env)->DeleteLocalRef(env,jMatrix);

    *transform = t;
    return result;
}

- (void)createJavaWebView:(int)texID
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jclass class = [[TNJavaHelper sharedHelper] findCustomClass:@"org.tiny4.CocoaActivity.GLWebViewRender"];
    
    if (class == NULL) {
        NSLog(@"class not found: %@",@"org.tiny4.CocoaActivity.GLWebViewRender");
        return;
    }

    jmethodID mid = (*env)->GetMethodID(env,class,"<init>","(Landroid/content/Context;III)V");
    if (mid == NULL) {
        NSLog(@"method id not found:%@",@"init  (Landroid/content/Context;III)V");
        return;
    }

    jclass clazz = [[TNJavaHelper sharedHelper] clazz];

    jint width = self.bounds.size.width;
    jint height = self.bounds.size.height;
    
    jobject object = (*env)->NewObject(env,class,mid,clazz,texID,width,height);

    if (object == NULL) {
        NSLog(@"create object failed");
        return;
    }
    
    _jWebView = (*env)->NewGlobalRef(env,object);
    _jWebViewClass = (*env)->NewGlobalRef(env,class);
    
    (*env)->DeleteLocalRef(env,class);
    (*env)->DeleteLocalRef(env,object);
}

- (void)setJavaWebViewSize:(CGSize)size
{
    if (_jWebView && _jWebViewClass) {
        JNIEnv *env = [[TNJavaHelper sharedHelper] env];
        
        jint width = size.width;
        jint height = size.height;
        
        jmethodID mid = (*env)->GetMethodID(env,_jWebViewClass,"setSize","(II)V");
        if (mid == NULL) {
            NSLog(@"can't get method setSize()");
        }
        (*env)->CallVoidMethod(env,_jWebView,mid,width,height);
    }

}
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    [self setJavaWebViewSize:bounds.size];
}

- (void)loadRequest:(NSURLRequest *)request
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];

    //webview.loadUrl("http://www.google.com/");
    jstring jUrl = (*env)->NewStringUTF(env,[request.URL.absoluteString UTF8String]);
    
    jmethodID mid = (*env)->GetMethodID(env,_jWebViewClass,"loadUrl","(Ljava/lang/String;)V");
    if (mid == NULL) {
        NSLog(@"method id not found:%@",@"loadUrl ()V");
        return;
    }
    
    (*env)->CallVoidMethod(env, _jWebView, mid,jUrl);

    (*env)->DeleteLocalRef(env,jUrl);
}

- (void)loadHTMLString:(NSString *)string MIMEType:(NSString *)MIMEType  baseURL:(NSURL *)baseURL
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    
    //webview.loadData(summary, "text/html", null);

    NSString *meta = MIMEType ? MIMEType : @"text/html";
    jstring jData = (*env)->NewStringUTF(env,[string UTF8String]);
    jstring jMeta = (*env)->NewStringUTF(env,[meta UTF8String]);
    jstring jBaseUrl = (*env)->NewStringUTF(env,[[baseURL absoluteString] UTF8String]);
    

    jmethodID mid = (*env)->GetMethodID(env,_jWebViewClass,"loadDataWithBaseURL","(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
    if (mid == NULL) {
        NSLog(@"method id not found:%@",@"loadDataWithBaseURL ()V");
        return;
    }

    (*env)->CallVoidMethod(env, _jWebView, mid,jBaseUrl,jData,jMeta,NULL,NULL);

    (*env)->DeleteLocalRef(env,jData);
    (*env)->DeleteLocalRef(env,jMeta);
    (*env)->DeleteLocalRef(env,jBaseUrl);
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [self loadHTMLString:string MIMEType:@"text/html" baseURL:baseURL];
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:textEncodingName];
    [self loadHTMLString:htmlString MIMEType:MIMEType baseURL:baseURL];
}

#pragma mark - Event forward
- (void)simulateTouches:(NSSet *)touches event:(UIEvent *)event
{    
    AInputEvent *aEvent = [event _AInputEvent];
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];

    UITouch *touch = [touches anyObject];
    
    int64_t downTime = AMotionEvent_getDownTime(aEvent)/1000000;
    int64_t eventTime = AMotionEvent_getEventTime(aEvent)/1000000;
    
    int action = AMotionEvent_getAction(aEvent);
    int32_t trueAction = action & AMOTION_EVENT_ACTION_MASK;
    
    CGPoint location = [touch locationInView:self];
//    NSLog(@"touch on web:%@ action:%d trueAction:%d",NSStringFromCGPoint(location),action,trueAction);
//    NSLog(@"eventTime:%lld downTime:%lld",eventTime,downTime);
    
    jlong x = (jlong)location.x;
    jlong y = (jlong)location.y;
    jint jaction = action;
    jlong jdownTime = downTime;
    jlong jeventTime = eventTime;
    jint jtrueAction = trueAction;

    
    //public boolean dispatchTouchEvent(android.view.MotionEvent ev)
    jmethodID mid = (*env)->GetMethodID(env,_jWebViewClass,"simulateTouch","(JJIJJ)V");
    if (mid == NULL) {
        NSLog(@"mithod id simulateTouch not found");
    }
    (*env)->CallVoidMethod(env,_jWebView,mid,jeventTime,jdownTime,jtrueAction,x,y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self simulateTouches:touches event:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self simulateTouches:touches event:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self simulateTouches:touches event:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self simulateTouches:touches event:event];
}
@end
