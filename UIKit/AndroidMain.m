//
//  AndroidMain.m
//  UIKit
//
//  Created by Chen Yonghui on 1/30/15.
//  Copyright (c) 2015 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "AndroidMain.h"

#include <string.h>
#include <jni.h>
#include <android/log.h>

#import <TNJavaHelper/TNJavaHelper.h>
#import <ObjectiveZip/ObjectiveZip.h>

#import "UIApplication.h"
#import "UIAndroidEventsServer.h"
#import "TNAConfiguration.h"

#import "UIAndroidEventsServer.h"

#import "UIScreenPrivate.h"

#import "BKRenderingService.h"

// HACK: private workaround method
@interface NSThread (Private)
+ (void)setCurrentThreadAsMainThread;
@end

@interface TNAndroidLauncher : NSObject
+ (void)launchWithArgc:(int)argc argv:(char *[])argv;
@end
@implementation TNAndroidLauncher
@end


#pragma mark -
/**
 * Shared state for our app.
 */
struct engine {
    struct android_app* app;
    
    JNIEnv *env;
    
    int animating;
    bool isScreenReady;
    bool isWarnStart;
};

struct android_app* app_state;
static AMEventsCallback _eventsCallback = NULL;
static BOOL _landscaped;

bool AMIsLandscaped()
{
    return _landscaped;
}

#pragma mark - GDB support
//workaround for call objc methods in gdb
//should move to Foundation or objc library
void* ___gdb_android_workaround_malloc(size_t size)
{
    return malloc(size);
}

#pragma mark Logging
static void _NSLog_android_log_handler (NSString *message)
{
    __android_log_write(ANDROID_LOG_INFO,"NSLog",[message UTF8String]);
}

static void constructExecutablePath(char *result, struct android_app* state)
{
    char buffer[1024];
    char basePath[1024];
    
    // externalDataPath: /storage/emulated/0/Android/data/com.company.example/files
    const char * externalDataPath = app_state->activity->externalDataPath;
    
    // remove last component
    // basePath will be formate like /storage/emulated/0/Android/data/com.company.example
    char *lastSlash = strrchr(externalDataPath, '/');
    strncpy(basePath, externalDataPath, lastSlash - externalDataPath);
    
    // get last component
    // activityIdentifier will be formate like com.company.example
    char activityIdentifier[1024];
    memset(activityIdentifier, 0, 1024);
    lastSlash = strrchr(basePath, '/');
    strcpy(activityIdentifier, lastSlash+1);
    
    // get product name
    // productName will be example
    char productName[1024];
    memset(productName, 0, 1024);
    char *lastDot = strrchr(activityIdentifier, '.');
    strcpy(productName, lastDot+1);
    
    // construct path
    memset(buffer, 0, 1024);
    sprintf(buffer, "%s/%s.app/%s",basePath,activityIdentifier,productName);
    
    strcpy(result, buffer);
}


#pragma mark - MainBundle
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

const char *getAPKPath()
{
    JNIEnv *env = [[TNJavaHelper sharedHelper] env];
    ANativeActivity *activity = app_state->activity;
    jclass clazz = (*env)->GetObjectClass(env, activity->clazz);
    jmethodID methodID = (*env)->GetMethodID(env, clazz, "getPackageCodePath", "()Ljava/lang/String;");
    jobject result = (*env)->CallObjectMethod(env, activity->clazz, methodID);
    
    jboolean isCopy;
    const char *res = (*env)->GetStringUTFChars(env,(jstring)result, &isCopy);
    
    (*env)->DeleteLocalRef(env,result);
    (*env)->DeleteLocalRef(env,clazz);
    
    return res;
}

static void _unzipAssetsToMainBundle(NSString *zipPath, NSString *path)
{
    ZipFile *file = [[ZipFile alloc] initWithFileName:zipPath mode:ZipFileModeUnzip];
    NSArray *fileInfos = [file listFileInZipInfos];
    [file goToFirstFileInZip];
    do {
        FileInZipInfo *info = [file getCurrentFileInZipInfo];
        NSString *fileName = [info name];
        if (! [fileName hasPrefix:@"assets/"]) {
            continue;
        }
        fileName = [fileName stringByDeletingPrefix:@"assets/"];
        
        NSString *destFilePath = [path stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:destFilePath]) {
            ZipReadStream *readStream = [file readCurrentFileInZip];
            NSMutableData *contentData = [[NSMutableData alloc] initWithLength:info.length];
            [readStream readDataWithBuffer:contentData];
            
            if ([contentData length] >0) {
                // create directory if not exists
                NSString *directory = [destFilePath stringByDeletingLastPathComponent];
                BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:directory];
                if (!directoryExists) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
                }
                
                // write contents
                NSError *writeError = nil;
                BOOL success = [contentData writeToFile:destFilePath options:NSDataWritingAtomic error:&writeError];
                if (!success) {
                    NSLog(@"unzip data to path %@ failed. error:%@",destFilePath,[writeError localizedDescription]);
                }
            }
            [readStream finishedReading];
            
        }
    } while ([file goToNextFileInZip]);
    
    [file close];
}

static void _prepareAsset(NSString *path)
{
    const char *apkPathUTF8 = getAPKPath();
    NSString *apkPath = [NSString stringWithUTF8String:apkPathUTF8];
    NSDictionary *attributes = [[NSFileManager defaultManager] fileAttributesAtPath:apkPath traverseLink:NO];
    NSDate *modificationDate = attributes[NSFileModificationDate];
    
    NSDate *lastModificationDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"TN_APKFileModificationDate"];
    if (!lastModificationDate ||
        ![lastModificationDate isEqualToDate:modificationDate]) {
        
        // extract folder
        NSLog(@"unziping apk to path:%@",path);
        _unzipAssetsToMainBundle(apkPath, path);
        
        [[NSUserDefaults standardUserDefaults] setObject:modificationDate forKey:@"TN_APKFileModificationDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"apk unchanged, skip unzip");
    }
}

#pragma mark - Fontconfig
void _createFontconfigFile(NSString *path, NSString *cachePath)
{
    NSString *fontPath = [[cachePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"files/fonts"];
    
    NSString *cache = [NSString stringWithFormat:@"<?xml version=\"1.0\"?><!DOCTYPE fontconfig SYSTEM \"fonts.dtd\"><fontconfig><dir>/system/fonts</dir><dir>%@</dir><cachedir>%@</cachedir>",fontPath, cachePath];
    NSString *end = @"<match><test name=\"lang\"><string>en</string></test><edit name=\"family\" mode=\"prepend_first\"><string>Phantom Open Emoji</string></edit></match><match><test name=\"lang\"><string>ar</string></test><edit name=\"family\" mode=\"prepend_first\"><string>Droid Naskh Shift Alt</string></edit></match><match><test name=\"lang\"><string>ja</string></test><edit name=\"family\" mode=\"prepend_first\"><string>MotoyaLMaru</string></edit></match><match><test name=\"lang\"><string>th</string></test><edit name=\"family\" mode=\"prepend_first\"><string>Droid Sans Thai</string></edit></match><match><test name=\"lang\"><string>ru</string></test><edit name=\"family\" mode=\"append_last\"><string>Roboto</string></edit></match><match><test name=\"family\"><string>Roboto</string></test><edit name=\"file\" mode=\"prepend_first\"><string>/system/fonts/Roboto-Regular.ttf</string></edit></match><match><test name=\"family\"><string>Helvetica</string></test><edit name=\"family\" mode=\"prepend\" binding=\"strong\"><string>Droid Sans Fallback</string></edit></match><match><test name=\"family\"><string>Helvetica Neue</string></test><edit name=\"family\" mode=\"prepend\" binding=\"strong\"><string>Droid Sans Fallback</string></edit></match><match target=\"font\"><edit mode=\"assign\" name=\"hinting\"><bool>true</bool></edit></match><match target=\"font\"><edit mode=\"assign\" name=\"hintstyle\"><const>hintmedium</const></edit></match></fontconfig>";
    NSString *finalContent = [cache stringByAppendingString:end];
    
    [finalContent writeToFile:path atomically:YES];
}

void _configureFontconfigEnv(struct android_app* app)
{
    NSString *internalDataPath = [NSString stringWithCString:app->activity->internalDataPath];
    
    // FIXME: hard code cache path is ugly
    NSString *cachePath = [[internalDataPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"cache"];
    
    
    NSString *fontconfigFilePath = [cachePath stringByAppendingPathComponent:@"fontconfig.conf"];
    // settign font config file env
    setenv("FONTCONFIG_FILE",[fontconfigFilePath UTF8String],1);
    
    // create font config file if not exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:fontconfigFilePath]) {
        _createFontconfigFile(fontconfigFilePath, cachePath);
    }
}


@interface MainThreadLaunch : NSObject
@end
@implementation MainThreadLaunch

static int _argc;
static char *_argv[];

+ (void)launch
{
    // Cheat current current thread as main thread
    // The default main thread(thread 0), which is Android's Java side
    // Java side run our codes on secondly thread (thread 1)
    // we treat thread 1 as main thread, to keep our codes insulate with Java,
    // and gain ability to run our runloop.
    [NSThread setCurrentThreadAsMainThread];
    
    //JAVA: vm->AttachCurrentThread
    [[TNJavaHelper sharedHelper] env];
    
    [TNAndroidLauncher launchWithArgc:_argc argv:_argv];
}

@end

#pragma mark Display setup
/**
 * Initialize an EGL context for the current display.
 */
static int engine_init_display(struct engine* engine) {
    BKRenderingServiceBegin(engine->app);
    CGRect bounds = BKRenderingServiceGetPixelBounds();
    
    TNAConfiguration *config = [[TNAConfiguration alloc] initWithAConfiguration:engine->app->config];
    _landscaped = (config.orientation == TNAConfigurationOrientationLand);
    
    [[UIScreen mainScreen] _setPixelBounds:bounds];
    
    NSLog(@"screen pixel size:%@",NSStringFromCGSize(bounds.size));
    
    return 0;
}

/**
 * Tear down the EGL context currently associated with the display.
 */
static void engine_term_display(struct engine* engine) {
    BKRenderingServiceEnd();
}

#pragma mark Events

void handle_app_command(struct android_app* app, int32_t cmd) {
    /* app->userData is available here */
    
    struct engine* engine = (struct engine*)app->userData;
    switch (cmd) {
        case APP_CMD_INIT_WINDOW:
            engine_init_display(engine);
            engine->isScreenReady = true;
            if (engine->isWarnStart) {
                BKRenderingServiceRun();
                //FIXME:should reload textures here
            }
            engine->isWarnStart = true;
            break;
        case APP_CMD_TERM_WINDOW:
            // The window is being hidden or closed, clean it up.
            engine_term_display(engine);
            engine->app->window = NULL;
            engine->isScreenReady = false;
            break;
        case APP_CMD_LOST_FOCUS:
            // Also stop animating.
            engine->animating = 0;
            break;
        case APP_CMD_GAINED_FOCUS:
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
            _landscaped = (config.orientation == TNAConfigurationOrientationLand);
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



#pragma mark - Entry point
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
        
        // Make sure glue isn't stripped.
        app_dummy();
        
        _configureFontconfigEnv(app_state);
        
        //setup engine
        struct engine engine;
        memset(&engine, 0, sizeof(engine));
        app_state->userData = &engine;
        app_state->onAppCmd = handle_app_command;
        engine.app = app_state;
        
        // attach current thread to java vm, so we can call java code
        [TNJavaHelper initializeWithVM:state->activity->vm activityClass:state->activity->clazz];
        engine.env = [[TNJavaHelper sharedHelper] env];
        
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
        _argc = argc;
        [NSThread detachNewThreadSelector:@selector(launch) toTarget:[MainThreadLaunch class] withObject:nil];
        
        // never return
        UIAndroidEventsServerStart(app_state);
    }
    
}

#pragma mark - Public Access
void AMRegisterEventsCallback(AMEventsCallback callback)
{
    _eventsCallback = callback;
}