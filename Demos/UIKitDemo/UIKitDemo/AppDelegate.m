//
//  AppDelegate.m
//  UIKitDemo
//
//  Created by Chen Yonghui on 1/24/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    // Override point for customization after application launch.
    #if __ANDROID__
    	[[UIScreen mainScreen] setScreenMode:UIScreenSizeModePad scale:0];
    #endif
    						
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc = [[ViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [self checkMainBundle];
//    [self checkGnustepPathConfig];
    return YES;
}

- (void)logDirectoriesForDomain:(NSSearchPathDomainMask)domainMask
{
    NSLog(@"========");
    NSLog(@"NSSearchPathForDirectoriesInDomains: %d",domainMask);
//    
    NSLog(@"NSApplicationDirectory:%@",NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, domainMask, YES));
    NSLog(@"NSDemoApplicationDirectory:%@",NSSearchPathForDirectoriesInDomains(NSDemoApplicationDirectory, domainMask, YES));
    NSLog(@"NSDeveloperApplicationDirectory:%@",NSSearchPathForDirectoriesInDomains(NSDeveloperApplicationDirectory, domainMask, YES));
    NSLog(@"NSAdminApplicationDirectory:%@",NSSearchPathForDirectoriesInDomains(NSAdminApplicationDirectory, domainMask, YES));
    NSLog(@"NSLibraryDirectory:%@",NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, domainMask, YES));
    NSLog(@"NSDeveloperDirectory:%@",NSSearchPathForDirectoriesInDomains(NSDeveloperDirectory, domainMask, YES));
    NSLog(@"NSUserDirectory:%@",NSSearchPathForDirectoriesInDomains(NSUserDirectory, domainMask, YES));
    NSLog(@"NSDocumentationDirectory:%@",NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, domainMask, YES));
    NSLog(@"NSDocumentDirectory:%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, domainMask, YES));
#if __ANDROID__
    NSLog(@"NSCoreServicesDirectory:%@",NSSearchPathForDirectoriesInDomains(NSCoreServicesDirectory, domainMask, YES));
#else
    NSLog(@"NSCoreServiceDirectory:%@",NSSearchPathForDirectoriesInDomains(NSCoreServiceDirectory, domainMask, YES));
#endif
    NSLog(@"NSDesktopDirectory:%@",NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, domainMask, YES));
    NSLog(@"NSCachesDirectory:%@",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, domainMask, YES));
    NSLog(@"NSApplicationSupportDirectory:%@",NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, domainMask, YES));
    NSLog(@"NSDownloadsDirectory:%@",NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, domainMask, YES));

    NSLog(@"NSAllApplicationsDirectory:%@",NSSearchPathForDirectoriesInDomains(NSAllApplicationsDirectory, domainMask, YES));
    NSLog(@"NSCachesDirectory:%@",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, domainMask, YES));
    NSLog(@"NSAllLibrariesDirectory:%@",NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, domainMask, YES));
    NSLog(@"NSApplicationSupportDirectory:%@",NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, domainMask, YES));

#if __ANDROID__
    NSLog(@"GSLibrariesDirectory:%@",NSSearchPathForDirectoriesInDomains(GSLibrariesDirectory, domainMask, YES));
    NSLog(@"GSToolsDirectory:%@",NSSearchPathForDirectoriesInDomains(GSToolsDirectory, domainMask, YES));
    NSLog(@"GSFontsDirectory:%@",NSSearchPathForDirectoriesInDomains(GSFontsDirectory, domainMask, YES));
    NSLog(@"GSFrameworksDirectory:%@",NSSearchPathForDirectoriesInDomains(GSFrameworksDirectory, domainMask, YES));
    NSLog(@"GSWebApplicationsDirectory:%@",NSSearchPathForDirectoriesInDomains(GSWebApplicationsDirectory, domainMask, YES));
    NSLog(@"GSAdminToolsDirectory:%@",NSSearchPathForDirectoriesInDomains(GSAdminToolsDirectory, domainMask, YES));
#endif
}
- (void)checkGnustepPathConfig
{
    NSLog(@"NSTemporaryDirectory()%@",NSTemporaryDirectory());
    NSLog(@"NSHomeDirectory():%@",NSHomeDirectory());
    NSLog(@"NSUserName():%@",NSUserName());
    NSLog(@"NSFullUserName():%@",NSFullUserName());
    NSLog(@"NSHomeDirectoryForUser(%@):%@",NSUserName(),NSHomeDirectoryForUser(NSUserName()));
    NSLog(@"NSOpenStepRootDirectory():%@",NSOpenStepRootDirectory());
    [self logDirectoriesForDomain:NSAllDomainsMask];
    
    NSLog(@"========");
    NSLog(@"-[NSFileManager URLsForDirectory:inDomains]: user domain");
    NSLog(@"NSDocumentDirectory:%@",[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]);
    NSLog(@"NSLibraryDirectory:%@",[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask]);
    NSLog(@"NSCachesDirectory:%@",[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask]);

}

- (void)checkMainBundle
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundlePath = [mainBundle bundlePath];
    
    NSLog(@"main bundle path:%@",bundlePath);
    NSLog(@"listing main bundle contents:");
    NSFileManager *fm =[NSFileManager defaultManager];
    NSArray *contents = [fm contentsOfDirectoryAtPath: bundlePath error:nil];
    NSLog(@"%@",contents);
    
    if (contents.count == 0) {
        NSLog(@"[Warning] empty main bundle contents?");
        return;
    }
    
    // check pathForResource:ofType:
    NSString *oneFile = contents[0];
    NSString *icon = [mainBundle pathForResource:oneFile ofType:nil];
    if (!icon) {
        NSLog(@"[Warning] main bundle has contents, but pathForResource:ofType: return nil. this happended if you init main bundle before expand contents to main bundle directory");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (![NSThread isMainThread]) {
        NSLog(@"[ERROR] should called in mainthread");
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (![NSThread isMainThread]) {
        NSLog(@"[ERROR] should called in mainthread");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (![NSThread isMainThread]) {
        NSLog(@"[ERROR] should called in mainthread");
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (![NSThread isMainThread]) {
        NSLog(@"[ERROR] should called in mainthread");
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (![NSThread isMainThread]) {
        NSLog(@"[ERROR] should called in mainthread");
    }
}

@end
