//
//  UIVideoEditorController.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UINavigationController.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIImagePickerController.h>

@protocol UIVideoEditorControllerDelegate;

@interface UIVideoEditorController : UINavigationController
+ (BOOL)canEditVideoAtPath:(NSString *)videoPath;

@property(nonatomic,assign)    id <UINavigationControllerDelegate, UIVideoEditorControllerDelegate> delegate;

@property(nonatomic, copy)     NSString                              *videoPath;
@property(nonatomic)           NSTimeInterval                        videoMaximumDuration;
@property(nonatomic)           UIImagePickerControllerQualityType    videoQuality;

@end

@protocol UIVideoEditorControllerDelegate<NSObject>
@optional
- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath;
- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error;
- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor;

@end
