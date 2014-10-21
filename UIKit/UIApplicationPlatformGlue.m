//
//  UIApplicationPlatformGlue.m
//  UIKit
//
//  Created by Chen Yonghui on 7/11/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIApplicationPlatformGlue.h"

#import <QuartzCore/QuartzCore.h>
#import "UIScreenPrivate.h"

#include <string.h>
#include <jni.h>
#include <android/log.h>
#import <Foundation/NSObjCRuntime.h>
#include "android_native_app_glue.h"

#include <EGL/egl.h>
#include <GLES2/gl2.h>

#define ANDROID 1
#import <OpenGLES/EAGL.h>

#import "BKRenderingService.h"
#import "TNAConfiguration.h"

// HACK: private workaround method
@interface NSThread (Private)
+ (void)setCurrentThreadAsMainThread;
@end

@interface TNAndroidLauncher : NSObject
+ (void)launchWithArgc:(int)argc argv:(char *[])argv;
@end
@implementation TNAndroidLauncher
@end

@implementation UIApplicationPlatformGlue

#pragma mark - Android glue
static void handle_app_command(struct android_app* app, int32_t cmd);
static int32_t handle_input(struct android_app* app, AInputEvent* event);
bool app_has_focus = false;
static struct android_app* app_state;
static EAGLContext *_mainContext = nil;
static CARenderer *_mainRenderer = nil;

/**
 * Shared state for our app.
 */
struct engine {
    struct android_app* app;
    
    int animating;
    bool isScreenReady;
};

static void constructExecutablePath(char *result, struct android_app* state)
{
    char buffer[1024];
    char basePath[1024];
    
    // externalDataPath: /storage/emulated/0/Android/data/org.tiny4.BasicCairo/files
    const char * externalDataPath = app_state->activity->externalDataPath;
    
    // remove last component
    char *lastSlash = strrchr(externalDataPath, '/');
    strncpy(basePath, externalDataPath, lastSlash - externalDataPath);
    
    // get last component
    char activityName[1024];
    memset(activityName, 0, 1024);
    lastSlash = strrchr(basePath, '/');
    strcpy(activityName, lastSlash+1);
    
    // construct path
    memset(buffer, 0, 1024);
    sprintf(buffer, "%s/%s.app/UIKitApp",basePath,activityName);
    
    strcpy(result, buffer);
}

//workaround for call objc methods in gdb
//should move to Foundation or objc library
void* ___gdb_android_workaround_malloc(size_t size)
{
    return malloc(size);
}

// Entry point from android part
void android_main(struct android_app* state)
{
    @autoreleasepool {
        
        // Forward NSLog to android logging system
        _NSLog_printf_handler = *_NSLog_android_log_handler;
        
        app_state = state;
        
        char buffer[1024];
        constructExecutablePath(buffer, state);
        
        // Initialize process info
        int argc = 1;
        char * argv[] = {buffer};
        [NSProcessInfo initializeWithArguments:argv count:argc environment:NULL];
        
        // Cheat current current thread as main thread
        // The default main thread(thread 0), which is Android's Java side
        // Java side run our codes on secondly thread (thread 1)
        // we treat thread 1 as main thread, to keep our codes insulate with Java,
        // and gain ability to run our runloop.
        [NSThread setCurrentThreadAsMainThread];
        
        // Make sure glue isn't stripped.
        app_dummy();
        
        NSString *internalDataPath = [NSString stringWithCString:app_state->activity->internalDataPath];
        
        // FIXME: hard code cache path is ugly
        NSString *cachePath = [[internalDataPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"cache"];
        
        
        NSString *fontconfigFilePath = [cachePath stringByAppendingPathComponent:@"fontconfig.conf"];
        // settign font config file env
        setenv("FONTCONFIG_FILE",[fontconfigFilePath UTF8String],1);
        
        // create font config file if not exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:fontconfigFilePath]) {
            _createFontconfigFile(fontconfigFilePath, cachePath);
        }
        
        //setup engine
        struct engine engine;
        memset(&engine, 0, sizeof(engine));
        app_state->userData = &engine;
        app_state->onAppCmd = handle_app_command;
        app_state->onInputEvent = handle_input;
        engine.app = app_state;
        
        // Wait until screen is ready
        // which is wait to receive APP_CMD_INIT_WINDOW cmd
        while (!engine.isScreenReady) {
            int ident;
            int events;
            struct android_poll_source* source;
            int pollTimeout = 0;
            
            while ((ident=ALooper_pollAll(pollTimeout, NULL, &events, (void**)&source)) >= 0) {
                if (source != NULL) {
                    source->process(app_state, source);
                }
                
                if (engine.isScreenReady) {
                    break;
                }
            }
        }
        
        // unzip assets to bundle path
        NSString *bundlePath = [NSString stringWithUTF8String:buffer];
        bundlePath = [bundlePath stringByDeletingLastPathComponent];
        _prepareAsset(bundlePath);
        
        // call launcher, launcher will call the main()
        [TNAndroidLauncher launchWithArgc:argc argv:argv];
    }
    
}

#pragma mark Events

static void handle_app_command(struct android_app* app, int32_t cmd) {
    /* app->userData is available here */
    
    UIApplication *_app = [UIApplication sharedApplication];
    
    struct engine* engine = (struct engine*)app->userData;
    switch (cmd) {
        case APP_CMD_INIT_WINDOW:
            // The window is being shown, get it ready.
            if (engine->app->window != NULL) {
                engine_init_display(engine);
            }
            engine->isScreenReady = true;
            break;
        case APP_CMD_TERM_WINDOW:
            // The window is being hidden or closed, clean it up.
            engine_term_display(engine);
            break;
        case APP_CMD_LOST_FOCUS:
            app_has_focus=false;
            // Also stop animating.
            engine->animating = 0;
            break;
        case APP_CMD_GAINED_FOCUS:
            app_has_focus=true;
            break;
        case APP_CMD_INPUT_CHANGED:break;
        case APP_CMD_WINDOW_RESIZED:break;
        case APP_CMD_WINDOW_REDRAW_NEEDED:break;
        case APP_CMD_CONTENT_RECT_CHANGED:{
            ARect rect = app->contentRect;
            NSLog(@"contentRect:{%d,%d %d,%d}", rect.top,rect.left,rect.bottom,rect.right);
        } break;
        case APP_CMD_CONFIG_CHANGED: {
            TNAConfiguration *config = [[TNAConfiguration alloc] initWithAConfiguration:app->config];
            _app->_landscaped = (config.orientation == TNAConfigurationOrientationLand);
        } break;
        case APP_CMD_LOW_MEMORY:break;
        case APP_CMD_START:break;
        case APP_CMD_RESUME:break;
        case APP_CMD_SAVE_STATE:break;
        case APP_CMD_PAUSE:break;
        case APP_CMD_STOP:break;
        case APP_CMD_DESTROY:break;
    }
}

static int32_t handle_input(struct android_app* app, AInputEvent* aEvent) {
    /* app->userData is available here */
    [[UIApplication sharedApplication] handleAEvent:aEvent];
    return 1;
}

#pragma mark Display setup
/**
 * Initialize an EGL context for the current display.
 */
static int engine_init_display(struct engine* engine) {
    BKRenderingServiceBegin(engine->app);
    CGRect bounds = BKRenderingServiceGetPixelBounds();
    
    [[UIScreen mainScreen] _setPixelBounds:bounds];
    [[UIScreen mainScreen] _setScale:1];
    
    return 0;
}

/**
 * Tear down the EGL context currently associated with the display.
 */
static void engine_term_display(struct engine* engine) {
    BKRenderingServiceEnd();
}

#pragma mark Logging
static void _NSLog_android_log_handler (NSString *message)
{
    __android_log_write(ANDROID_LOG_INFO,"NSLog",[message UTF8String]);
}

#pragma mark MainBundle
#define BUFSIZ 1024

static void _extractFolder(NSString *folder, NSString *path)
{
    // we should not call [NSBundle mainBundle] before extract files to mainBundle's path
    NSString *destPath = [path stringByAppendingPathComponent:folder];
    if (! [[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        NSLog(@"create folder:%@",destPath);
        NSError *creationError = nil;
        BOOL createSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:destPath withIntermediateDirectories:YES attributes:nil error:&creationError];
        if (!createSuccess) {
            NSLog(@"%@",creationError);
        }
    }
    
    AAssetManager *mgr = app_state->activity->assetManager;
    //    NSLog(@"open dir:%@",folder);
    AAssetDir *assetDir = AAssetManager_openDir(mgr, [folder UTF8String]);
    const char * filename = NULL;
    while ((filename = AAssetDir_getNextFileName(assetDir)) != NULL) {
        //        NSLog(@"process filename:%s",filename);
        NSString *NS_filename = [NSString stringWithUTF8String:filename];
        const char *destion = [[destPath stringByAppendingPathComponent:NS_filename] UTF8String];
        FILE *isExist = fopen(destion, "r");
        if (isExist) {
            //FIXME: what if the file is updated?
            //            NSLog(@"skip exist file:%s",destion);
            fclose(isExist);
            continue;
        }
        
        NSString *relativePath = [folder stringByAppendingPathComponent:NS_filename];
        //        NSLog(@"relativePath:%@",relativePath);
        //        NSLog(@"extract bundle file: %s",destion);
        AAsset *asset = AAssetManager_open(mgr, [relativePath UTF8String], AASSET_MODE_STREAMING);
        //        NSLog(@"asset:<%p>",asset);
        char buf[BUFSIZ];
        int nb_read = 0;
        FILE *out = fopen(destion, "w");
        while ((nb_read = AAsset_read(asset, buf, BUFSIZ)) > 0) {
            fwrite(buf, nb_read, 1, out);
        }
        fclose(out);
        AAsset_close(asset);
    }
    AAssetDir_close(assetDir);
    
}

static void _prepareAsset(NSString *path)
{
    //
    // FIXME: should only check files after the apk file changed
    //
    
    // we should not call [NSBundle mainBundle] before extract files to mainBundle's path
    // FIXME: workaround, should enumerate subfolders.
    _extractFolder(@"",path);
    _extractFolder(@"Resources",path);
    _extractFolder(@"Resources/UIKit.bundle",path);
    
    //    NSLog(@"main resourcePath: %@",[[NSBundle mainBundle] resourcePath]);
    //    NSLog(@"main bundlePath: %@",[[NSBundle mainBundle] bundlePath]);
    //    NSLog(@"main executablePath: %@",[[NSBundle mainBundle] executablePath]);
    
}

void _createFontconfigFile(NSString *path, NSString *cachePath)
{
    NSString *cache = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><!DOCTYPE fontconfig SYSTEM \"fonts.dtd\"><fontconfig><dir>/system/fonts</dir><cachedir>%@</cachedir>",cachePath];
    NSString *end = @"<match><test name=\"lang\"><string>en</string></test><edit name=\"family\" mode=\"prepend_first\"><string>Phantom Open Emoji</string></edit></match><match><test name=\"lang\"><string>ar</string></test><edit name=\"family\" mode=\"prepend_first\"><string>Droid Naskh Shift Alt</string></edit></match><match><test name=\"lang\"><string>ja</string></test><edit name=\"family\" mode=\"prepend_first\"><string>MotoyaLMaru</string></edit></match><match><test name=\"lang\"><string>th</string></test><edit name=\"family\" mode=\"prepend_first\"><string>Droid Sans Thai</string></edit></match><match><test name=\"lang\"><string>ru</string></test><edit name=\"family\" mode=\"append_last\"><string>Roboto</string></edit></match><match><test name=\"family\"><string>Helvetica</string></test><edit name=\"family\" mode=\"append_last\"><string>Roboto</string></edit></match><match><test name=\"family\"><string>Roboto</string></test><edit name=\"file\" mode=\"prepend_first\"><string>/system/fonts/Roboto-Regular.ttf</string></edit></match><match target=\"font\"><edit mode=\"assign\" name=\"hinting\"><bool>true</bool></edit></match><match target=\"font\"><edit mode=\"assign\" name=\"hintstyle\"><const>hintmedium</const></edit></match></fontconfig>";
    NSString *finalContent = [cache stringByAppendingString:end];
    
    [finalContent writeToFile:path atomically:YES];
}

@end
