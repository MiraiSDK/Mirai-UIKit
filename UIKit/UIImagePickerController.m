//
//  UIImagePickerController.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIImagePickerController.h"

@implementation UIImagePickerController

NSString *const UIImagePickerControllerMediaType = @"UIImagePickerControllerMediaType";
NSString *const UIImagePickerControllerOriginalImage = @"UIImagePickerControllerOriginalImage";
NSString *const UIImagePickerControllerEditedImage = @"UIImagePickerControllerEditedImage";
NSString *const UIImagePickerControllerCropRect = @"UIImagePickerControllerCropRect";
NSString *const UIImagePickerControllerMediaURL = @"UIImagePickerControllerMediaURL";
NSString *const UIImagePickerControllerReferenceURL = @"UIImagePickerControllerReferenceURL";
NSString *const UIImagePickerControllerMediaMetadata = @"UIImagePickerControllerMediaMetadata";

+ (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)sourceType
{
    return NO;
}

+ (NSArray *)availableMediaTypesForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    return @[];
}

+ (BOOL)isCameraDeviceAvailable:(UIImagePickerControllerCameraDevice)cameraDevice
{
    return NO;
}

+ (BOOL)isFlashAvailableForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice
{
    return NO;
}

+ (NSArray *)availableCaptureModesForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice
{
    return @[];
}

- (void)takePicture
{
    
}

- (BOOL)startVideoCapture
{
    return NO;
}

- (void)stopVideoCapture
{
    
}
@end

void UIImageWriteToSavedPhotosAlbum(UIImage *image, id completionTarget, SEL completionSelector, void *contextInfo)
{
    
}

BOOL UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(NSString *videoPath)
{
    return NO;
}

void UISaveVideoAtPathToSavedPhotosAlbum(NSString *videoPath, id completionTarget, SEL completionSelector, void *contextInfo)
{
    
}
