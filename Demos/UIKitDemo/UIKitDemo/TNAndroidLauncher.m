//
//  TNAndroidLauncher.m
//  UIKitDemo
//
//  Created by Chen Yonghui on 1/24/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNAndroidLauncher.h"

extern int main(int argc, char * argv[]);

@implementation TNAndroidLauncher (User)
+ (void)launchWithArgc:(int)argc argv:(char *[])argv
{
    main(argc,argv);
}
@end
