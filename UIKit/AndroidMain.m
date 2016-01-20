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
#import "unzip.h"

#import "UIApplication.h"
#import "UIApplication+UIPrivate.h"
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

static const char *replacePrefixAsNewString(const char *originalStr, const char *replacedStr, size_t prefixLen) {
    
    size_t replacedStrLen = strlen(replacedStr);
    size_t newStrLen = replacedStrLen + strlen(originalStr) - prefixLen;
    char *newStr = malloc(sizeof(char)*(newStrLen + 1));
    
    for (int i=0; i<replacedStrLen; i++) {
        newStr[i] = replacedStr[i];
    }
    
    for (int i=0; i<newStrLen - replacedStrLen; i++) {
        newStr[replacedStrLen + i] = originalStr[prefixLen + i];
    }
    newStr[newStrLen] = '\0';
    
    return newStr;
}

static void constructExecutablePath(char *result, struct android_app* state)
{
    char buffer[1024];
    char basePath[1024];
    
    // externalDataPath: /storage/emulated/0/Android/data/com.company.example/files
    const char * externalDataPath = app_state->activity->externalDataPath;
    
    // Some of Android devices (like MIUI3) don't have '0' directory.
    externalDataPath = replacePrefixAsNewString(externalDataPath,
                                                "/storage/emulated/legacy",
                                                strlen("/storage/emulated/0"));
    
    // remove last component
    // basePath will be formate like /storage/emulated/0/Android/data/com.company.example
    char *lastSlash = strrchr(externalDataPath, '/');
    strncpy(basePath, externalDataPath, lastSlash - externalDataPath);
    free(externalDataPath);
    
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

const char *getAPKPath(JNIEnv *env)
{
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


static void _miniUnzipAssetsToMainBundle(NSString *zipPath, NSString *path)
{
#define dir_delimter '/'
#define MAX_FILENAME 512
#define READ_SIZE 8192

    const char *zipPathUTF8 = [zipPath UTF8String];
    
    unzFile *zipfile = unzOpen64(zipPathUTF8);
    
    if (zipfile == NULL) {
        __android_log_print(ANDROID_LOG_ERROR,"NSLog","could not open file:%s\n", zipPathUTF8);
        return;
    }
    
    
    // Get info about the zip file
    unz_global_info global_info;
    if ( unzGetGlobalInfo( zipfile, &global_info ) != UNZ_OK )
    {
        __android_log_write(ANDROID_LOG_ERROR,"NSLog","could not read file global info\n");
        unzClose( zipfile );
        return;
    }
    
    
    // Buffer to hold data read from the zip file.
    char read_buffer[ READ_SIZE ];

    // Loop to extract all files
    uLong i;
    for ( i = 0; i < global_info.number_entry; ++i )
    {
        // Get info about current file.
        unz_file_info file_info;
        char filename[ MAX_FILENAME ];
        if ( unzGetCurrentFileInfo(
                                   zipfile,
                                   &file_info,
                                   filename,
                                   MAX_FILENAME,
                                   NULL, 0, NULL, 0 ) != UNZ_OK )
        {
            __android_log_write(ANDROID_LOG_ERROR,"NSLog","could not read file info\n");
            unzClose( zipfile );
            return;
        }
        
        NSString *oneFileName = [NSString stringWithUTF8String:filename];
        if ([oneFileName hasPrefix:@"assets/"]) {
            oneFileName = [oneFileName stringByDeletingPrefix:@"assets/"];
            
            NSString *destFilePath = [path stringByAppendingPathComponent:oneFileName];
            
            // Check if this entry is a directory or file.
            const size_t filename_length = strlen( filename );
            if ( filename[ filename_length-1 ] == dir_delimter ) {
                // Entry is a directory, so create it.
                __android_log_print(ANDROID_LOG_VERBOSE,"NSLog","dir:%s\n", filename);
                
                [[NSFileManager defaultManager] createDirectoryAtPath:destFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                
            } else {
                // Entry is a file, so extract it.
                __android_log_print(ANDROID_LOG_VERBOSE,"NSLog","file:%s\n", filename);
                
                
                if ( unzOpenCurrentFile( zipfile ) != UNZ_OK )
                {
                    __android_log_write(ANDROID_LOG_ERROR,"NSLog","could not open file\n");
                    unzClose( zipfile );
                    return;
                }
                
                NSString *directory = [destFilePath stringByDeletingLastPathComponent];
                BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:directory];
                if (!directoryExists) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
                }
                
                // Open a file to write out the data.
                FILE *out = fopen( [destFilePath UTF8String], "wb" );
                if ( out == NULL )
                {
                    __android_log_print(ANDROID_LOG_ERROR,"NSLog","could not open destination file:%s\n",[destFilePath UTF8String]);
                    unzCloseCurrentFile( zipfile );
                    unzClose( zipfile );
                    return;
                }
                
                
                int error = UNZ_OK;
                do
                {
                    error = unzReadCurrentFile( zipfile, read_buffer, READ_SIZE );
                    if ( error < 0 )
                    {
                        
                        __android_log_print(ANDROID_LOG_ERROR,"NSLog","error %d\n", error);
                        
                        unzCloseCurrentFile( zipfile );
                        unzClose( zipfile );
                        return;
                    }
                    
                    // Write data to file.
                    if ( error > 0 )
                    {
                        fwrite( read_buffer, error, 1, out ); // You should check return of fwrite...
                    }
                } while ( error > 0 );
                
                fclose( out );
            }
            
            unzCloseCurrentFile( zipfile );
        } else {
            __android_log_print(ANDROID_LOG_VERBOSE,"NSLog","ignore:%s\n", filename);
        }
        
        // Go the the next entry listed in the zip file.
        if ( ( i+1 ) < global_info.number_entry )
        {
            if ( unzGoToNextFile( zipfile ) != UNZ_OK )
            {
                __android_log_print(ANDROID_LOG_ERROR,"NSLog","cound not read next file\n");

                unzClose( zipfile );
                return;
            }
        }
    }


    
    unzClose(zipfile);
    
}

static void _prepareAsset(NSString *path,JNIEnv *env)
{
    const char *apkPathUTF8 = getAPKPath(env);
    NSString *apkPath = [NSString stringWithUTF8String:apkPathUTF8];
    NSDictionary *attributes = [[NSFileManager defaultManager] fileAttributesAtPath:apkPath traverseLink:NO];
    NSDate *modificationDate = attributes[NSFileModificationDate];
    
    NSDate *lastModificationDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"TN_APKFileModificationDate"];
    if (!lastModificationDate ||
        ![lastModificationDate isEqualToDate:modificationDate]) {
        
        // extract folder
        __android_log_print(ANDROID_LOG_VERBOSE,"NSLog","unziping apk to path:%s",[path UTF8String]);
        
        _miniUnzipAssetsToMainBundle(apkPath, path);
        
        [[NSUserDefaults standardUserDefaults] setObject:modificationDate forKey:@"TN_APKFileModificationDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        __android_log_write(ANDROID_LOG_VERBOSE,"NSLog","apk unchanged, skip unzip");
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

static void engine_set_should_refresh_screen(shouldRefreshScreen) {
    BKRenderingSetShouldRefreshScreen(shouldRefreshScreen);
}

#pragma mark Events

void handle_app_command(struct android_app* app, int32_t cmd) {
    /* app->userData is available here */
    
    struct engine* engine = (struct engine*)app->userData;
    switch (cmd) {
        case APP_CMD_INIT_WINDOW:
            NSLog(@"CMD: INIT_WINDOW");
            engine_init_display(engine);
            engine->isScreenReady = true;
            if (engine->isWarnStart) {
                BKRenderingServiceRun();
                //FIXME:should reload textures here
            }
            engine->isWarnStart = true;
            break;
        case APP_CMD_TERM_WINDOW:
            NSLog(@"CMD: TERM_WINDOW");
            // The window is being hidden or closed, clean it up.
            engine_term_display(engine);
            engine->app->window = NULL;
            engine->isScreenReady = false;
            break;
        case APP_CMD_LOST_FOCUS:
            NSLog(@"CMD: LOST_FOCUS");

            // Also stop animating.
            engine->animating = 0;
            [[UIApplication sharedApplication] performSelectorOnMainThread:@selector(_appWillResignActive) withObject:nil waitUntilDone:YES];
            break;
        case APP_CMD_GAINED_FOCUS:
            NSLog(@"CMD: GAINED_FOCUS");

            NSLog(@"will call _appDidBecomeActive");
            [[UIApplication sharedApplication] performSelectorOnMainThread:@selector(_appDidBecomeActive) withObject:nil waitUntilDone:YES];
            
            break;
        case APP_CMD_INPUT_CHANGED:
            NSLog(@"CMD: INPUT_CHANGED");

            break;
        case APP_CMD_WINDOW_RESIZED:
            NSLog(@"CMD: WINDOW_RESIZED");

            break;
        case APP_CMD_WINDOW_REDRAW_NEEDED:
            NSLog(@"CMD: WINDOW_REDRAW_NEEDED");

            break;
        case APP_CMD_CONTENT_RECT_CHANGED:{
            NSLog(@"CMD: CONTENT_RECT_CHANGED");

            ARect rect = app->contentRect;
            NSLog(@"contentRect:{%d,%d %d,%d}", rect.top,rect.left,rect.bottom,rect.right);
        } break;
        case APP_CMD_LOW_MEMORY:
            NSLog(@"CMD: LOW_MEMORY");
            break;
        case APP_CMD_START:
            NSLog(@"CMD: START");
            engine_set_should_refresh_screen(YES);

            break;
        case APP_CMD_RESUME:
            NSLog(@"CMD: RESUME");
            engine_set_should_refresh_screen(NO);

            break;
        case APP_CMD_SAVE_STATE:
            NSLog(@"CMD: SAVE_STATE");

            break;
        case APP_CMD_PAUSE:
            NSLog(@"CMD: APP PAUSE");
            break;
        case APP_CMD_STOP:
            NSLog(@"CMD: APP STOP");
            break;
        case APP_CMD_DESTROY:
            NSLog(@"CMD: DESTORY");
            [[UIApplication sharedApplication] performSelectorOnMainThread:@selector(_appWillTerminate) withObject:nil waitUntilDone:YES];
            break;
    }
}


#pragma mark - Entry point
// Entry point from android part

static bool firstEntry = YES;

void createDirectory(NSSearchPathDirectory directory)
{
    NSURL *fileURL = [[[NSFileManager defaultManager] URLsForDirectory:directory inDomains:NSUserDomainMask] lastObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:NULL]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:fileURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

void createDirectories()
{
    createDirectory(NSDocumentDirectory);
    createDirectory(NSCachesDirectory);
    createDirectory(NSLibraryDirectory);
    createDirectory(NSApplicationDirectory);
    createDirectory(NSDesktopDirectory);
    createDirectory(NSApplicationSupportDirectory);
    createDirectory(NSDownloadsDirectory);
}

void android_main(struct android_app* state)
{
    @autoreleasepool {
        
        int argc = 1;
        
        // Forward NSLog to android logging system
        _NSLog_printf_handler = *_NSLog_android_log_handler;
        
        app_state = state;
        
        NSString *appPath;
        if (firstEntry) {
            char buffer[1024];
            constructExecutablePath(buffer, state);
            appPath = [NSString stringWithUTF8String:buffer];
            
            const char *p = state->activity->internalDataPath;
            NSString *idp = [NSString stringWithCString:p encoding:NSUTF8StringEncoding];
            NSString *without_files = [idp stringByDeletingLastPathComponent];
            GSSetHomeDirectory([without_files UTF8String]);
            
            char tmpPath[strlen(p)+5];
            sprintf(tmpPath, "%s/tmp",p);
            
            char tmpEnv[strlen(p)+10];
            sprintf(tmpEnv, "TMP=%s/tmp",p);
            
            // Initialize process info
            argc = 1;
            char * argv[] = {buffer,NULL};
            char * eenv[] = {tmpEnv,"LANGUAGES=zh-Hans",NULL};
            [NSProcessInfo initializeWithArguments:argv count:argc environment:eenv];
            
            // Make sure glue isn't stripped.
            app_dummy();
            
            _configureFontconfigEnv(app_state);

            JavaVM *vm = app_state->activity->vm;
            JNIEnv *env;
            (*vm)->AttachCurrentThread(vm,&env,NULL);
            
            // unzip assets to bundle path
            // Note: before we unzip bundle contents, we should not init main bundle
            // means we should not direct/indirect call [NSBundle mainBundle]
            // which means we should not call NSLog()
            NSString *bundlePath = [appPath stringByDeletingLastPathComponent];
            _prepareAsset(bundlePath,env);
            
            //create TMP folder
            if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:tmpPath] isDirectory:NULL]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithUTF8String:tmpPath] attributes:nil];
            }
            
            //create subfolders(documents,cache,library...)
            createDirectories();
            
        }

        
        //setup engine
        struct engine engine;
        memset(&engine, 0, sizeof(engine));
        app_state->userData = &engine;
        app_state->onAppCmd = handle_app_command;
        engine.app = app_state;
        
        // attach current thread to java vm, so we can call java code
        // it's safe to attach thread multiple times
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
        
        
        if (firstEntry) {
            // call launcher, launcher will call the main()
            _argc = argc;
            [NSThread detachNewThreadSelector:@selector(launch) toTarget:[MainThreadLaunch class] withObject:nil];
            firstEntry = NO;

            // never return
            UIAndroidEventsServerStart(app_state);
        }
        
        NSLog(@"done android_main");

    }
    
}

#pragma mark - Public Access
void AMRegisterEventsCallback(AMEventsCallback callback)
{
    _eventsCallback = callback;
}