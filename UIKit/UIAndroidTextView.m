//
//  UIAndroidTextView.m
//  UIKit
//
//  Created by Chen Yonghui on 4/5/15.
//  Copyright (c) 2015 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIAndroidTextView.h"
#import <GLES2/gl2.h>
#import <TNJavaHelper/TNJavaHelper.h>
#import "UIEvent+Android.h"

typedef BOOL(^EAGLTextureUpdateCallback)(CATransform3D *t);

@interface CAMovieLayer : CALayer

@property (nonatomic, copy) EAGLTextureUpdateCallback updateCallback;
- (BOOL)updateTextureIfNeeds:(CATransform3D *)t;
- (int)textureID;

@end

@implementation UIAndroidTextView
{
    jobject _jTextView;
    jclass _jTextViewClass;
    JNIEnv *_env;
}
@synthesize textColor = _textColor;
@synthesize textAlignment = _textAlignment;
@synthesize font = _font;
@synthesize editable = _editable;

+ (Class)layerClass
{
    return [CAMovieLayer class];
}

- (void)destory
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jmethodID mid = (*env)->GetMethodID(env,_jTextViewClass,"onDestory","()V");
    if (mid == NULL) {
        NSLog(@"method not found: onDestory()");
        return;
    }
    NSLog(@"env:%p mid:%p, class:%p obj:%p",env,mid,_jTextViewClass,_jTextView);
    (*env)->CallVoidMethod(env,_jTextView,mid);
    
    (*env)->DeleteGlobalRef(env,_jTextViewClass);
    (*env)->DeleteGlobalRef(env,_jTextView);
}

- (void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    ((CAMovieLayer *)self.layer).updateCallback = nil;
    [self destory];
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
        [self createJavaTextView:tex];
    }
    return self;
}

- (BOOL)updaeTextureIfNeeds:(CATransform3D *)transform
{
    //    NSLog(@"%s",__PRETTY_FUNCTION__);
    static JNIEnv *env = NULL;
    if (env == NULL) {
        env = [[TNJavaHelper sharedHelper] env];
    }
    
    jmethodID mid = (*env)->GetMethodID(env,_jTextViewClass,"updateTextureIfNeeds","([F)I");
    if (mid == NULL) {
        NSLog(@"method id not found:%@",@"updateTextureIfNeeds ([F)I");
        return NO;
    }
    
    jfloatArray jMatrix = (*env)->NewFloatArray(env,16);
    
    jint result = (*env)->CallIntMethod(env, _jTextView, mid,jMatrix);
    
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

- (void)createJavaTextView:(int)texID
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jclass class = [[TNJavaHelper sharedHelper] findCustomClass:@"org.tiny4.CocoaActivity.GLTextViewRender"];
    
    if (class == NULL) {
        NSLog(@"class not found: %@",@"org.tiny4.CocoaActivity.GLTextViewRender");
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
    
    _jTextView = (*env)->NewGlobalRef(env,object);
    _jTextViewClass = (*env)->NewGlobalRef(env,class);
    
    (*env)->DeleteLocalRef(env,class);
    (*env)->DeleteLocalRef(env,object);
    
    NSThread *thread = [NSThread currentThread];
    NSLog(@"thread:%p",thread);
    NSLog(@"env:%p mid:%p, class:%p obj:%p",env,mid,_jTextViewClass,_jTextView);
}

#pragma mark -

- (void)setText:(NSString *)text
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jstring jData = (*env)->NewStringUTF(env,[text UTF8String]);
    jmethodID mid = (*env)->GetMethodID(env,_jTextViewClass,"setText","(Ljava/lang/CharSequence;)V");
    if (mid == NULL) {
        NSLog(@"method id not found:setText()");
        return;
    }
    
    (*env)->CallVoidMethod(env,_jTextView,mid,jData);
    (*env)->DeleteLocalRef(env,jData);

}

- (void)setTextColor:(UIColor *)textColor
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

    _textColor = textColor;
    
    CGFloat r,g,b,a;
    [textColor getRed:&r green:&g blue:&b alpha:&a];
    jint red = r * 255.0;
    jint green = g * 255.0;
    jint blue = b * 255.0;
    jint alpha = a * 255.0;
    NSLog(@"color: r:%.2f g:%.2f b:%.2f a:%.2f",r,g,b,a);
    NSLog(@"color: r:%d g:%d b:%d a:%d",red,green,blue,alpha);
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jmethodID mid = (*env)->GetMethodID(env,_jTextViewClass,"setTextColor","(IIII)V");
    if (mid == NULL) {
        NSLog(@"method id not found:setTextColor()");
        return;
    }
    
    (*env)->CallVoidMethod(env,_jTextView,mid,alpha,red,green,blue);

    
}

- (UIColor *)textColor
{
    return _textColor;
}

#define GRAVITY_TOP 48
#define GRAVITY_BOTTOM 80
#define GRAVITY_LEFT 3
#define GRAVITY_RIGHT 5
#define GRAVITY_CENTER_VERTICAL 16
#define GRAVITY_FILL_VERTICAL 112
#define GRAVITY_CENTER_HORIZONTAL 1
#define GRAVITY_FILL_HORIZONTAL 7
#define GRAVITY_CENTER 17
#define GRAVITY_FILL 119

#define TEXT_ALIGNMENT_INHERIT 0
#define TEXT_ALIGNMENT_GRAVITY 1
#define TEXT_ALIGNMENT_TEXT_START 2
#define TEXT_ALIGNMENT_TEXT_END 3
#define TEXT_ALIGNMENT_CENTER 4
#define TEXT_ALIGNMENT_VIEW_START 5
#define TEXT_ALIGNMENT_VIEW_END 6

- (void)setTextAlignment:(UITextAlignment)textAlignment
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

    _textAlignment = textAlignment;
    
    
    jint aAlignment = 2;
    jint gravity = GRAVITY_LEFT;
    switch (textAlignment) {
        case UITextAlignmentLeft:
            aAlignment = TEXT_ALIGNMENT_TEXT_START;
            gravity = GRAVITY_LEFT;
            break;
        case UITextAlignmentCenter:
            aAlignment = TEXT_ALIGNMENT_CENTER;
            gravity = GRAVITY_CENTER;
            break;
        case UITextAlignmentRight:
            aAlignment = TEXT_ALIGNMENT_TEXT_END;
            gravity = GRAVITY_RIGHT;

            break;
            
        default:
            break;
    }
    
    [self setGravity:gravity];
    return;
    
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jmethodID mid = (*env)->GetMethodID(env,_jTextViewClass,"setTextAlignment","(I)V");
    if (mid == NULL) {
        NSLog(@"method id not found: setTextAlignment()");
        return;
    }
    
    (*env)->CallVoidMethod(env,_jTextView,mid,aAlignment);
}

- (void)setGravity:(int)gravity
{
    
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jmethodID mid = (*env)->GetMethodID(env,_jTextViewClass,"setGravity","(I)V");
    if (mid == NULL) {
        NSLog(@"method id not found: setGravity()");
        return;
    }
    
    (*env)->CallVoidMethod(env,_jTextView,mid,gravity);

}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jmethodID mid = (*env)->GetMethodID(env,_jTextViewClass,"setHint","(Ljava/lang/CharSequence;)V");
    if (mid == NULL) {
        NSLog(@"method id not found: setHint()");
        return;
    }
    
    jstring hint = (*env)->NewStringUTF(env,[placeholder UTF8String]);
    (*env)->CallVoidMethod(env,_jTextView,mid,hint);
    (*env)->DeleteLocalRef(env,hint);

}

- (UITextAlignment)textAlignment
{
    return _textAlignment;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    NSString *fontName = [font fontName];
    CGFloat fontSize = 4;//font.xHeight;
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    jmethodID mid = (*env)->GetMethodID(env,_jTextViewClass,"setFont","(Ljava/lang/String;I)V");
    if (mid == NULL) {
        NSLog(@"method id not found: setFont()");
        return;
    }
    
    jstring jstr = (*env)->NewStringUTF(env,fontName.UTF8String);
    jint jfs = fontSize;
    NSLog(@"set fontName:%@ size:%d",fontName,jfs);
    (*env)->CallVoidMethod(env,_jTextView,mid,jstr,jfs);
    
    (*env)->DeleteLocalRef(env,jstr);
}

- (UIFont *)font
{
    return _font;
}

- (void)setEditable:(BOOL)editable
{
    _editable = editable;
}

- (BOOL)isEditable
{
    return _editable;
}

- (void)setSelectedRange:(NSRange)selectedRange
{
    
}

- (NSRange)selectedRange
{
    return NSMakeRange(NSNotFound, 0);
}

- (void)setContentOffset:(CGPoint)theOffset
{
    
}

- (void)scrollRangeToVisible:(NSRange)range
{
    
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    return YES;
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
    jmethodID mid = (*env)->GetMethodID(env,_jTextViewClass,"simulateTouch","(JJIJJ)V");
    if (mid == NULL) {
        NSLog(@"mithod id simulateTouch not found");
    }
    (*env)->CallVoidMethod(env,_jTextView,mid,jeventTime,jdownTime,jtrueAction,x,y);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self simulateTouches:touches event:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self simulateTouches:touches event:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self simulateTouches:touches event:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self simulateTouches:touches event:event];
}

@end
