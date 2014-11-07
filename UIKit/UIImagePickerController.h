//
//  UIImagePickerController.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UINavigationController.h>
#import <UIKit/UIKitDefines.h>

@class UIImage;
@protocol UIImagePickerControllerDelegate;

typedef NS_ENUM(NSInteger, UIImagePickerControllerSourceType) {
    UIImagePickerControllerSourceTypePhotoLibrary,
    UIImagePickerControllerSourceTypeCamera,
    UIImagePickerControllerSourceTypeSavedPhotosAlbum
};

typedef NS_ENUM(NSInteger, UIImagePickerControllerQualityType) {
    UIImagePickerControllerQualityTypeHigh = 0,       // highest quality
    UIImagePickerControllerQualityTypeMedium = 1,     // medium quality, suitable for transmission via Wi-Fi
    UIImagePickerControllerQualityTypeLow = 2,         // lowest quality, suitable for tranmission via cellular network
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    UIImagePickerControllerQualityType640x480 = 3,    // VGA quality
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
    UIImagePickerControllerQualityTypeIFrame1280x720 = 4,
    UIImagePickerControllerQualityTypeIFrame960x540 = 5
#endif
};

typedef NS_ENUM(NSInteger, UIImagePickerControllerCameraCaptureMode) {
    UIImagePickerControllerCameraCaptureModePhoto,
    UIImagePickerControllerCameraCaptureModeVideo
};

typedef NS_ENUM(NSInteger, UIImagePickerControllerCameraDevice) {
    UIImagePickerControllerCameraDeviceRear,
    UIImagePickerControllerCameraDeviceFront
};

typedef NS_ENUM(NSInteger, UIImagePickerControllerCameraFlashMode) {
    UIImagePickerControllerCameraFlashModeOff  = -1,
    UIImagePickerControllerCameraFlashModeAuto = 0,
    UIImagePickerControllerCameraFlashModeOn   = 1
};

// info dictionary keys
UIKIT_EXTERN NSString *const UIImagePickerControllerMediaType;      // an NSString (UTI, i.e. kUTTypeImage)
UIKIT_EXTERN NSString *const UIImagePickerControllerOriginalImage;  // a UIImage
UIKIT_EXTERN NSString *const UIImagePickerControllerEditedImage;    // a UIImage
UIKIT_EXTERN NSString *const UIImagePickerControllerCropRect;       // an NSValue (CGRect)
UIKIT_EXTERN NSString *const UIImagePickerControllerMediaURL;       // an NSURL
UIKIT_EXTERN NSString *const UIImagePickerControllerReferenceURL       ;
UIKIT_EXTERN NSString *const UIImagePickerControllerMediaMetadata ;

@interface UIImagePickerController : UINavigationController <NSCoding>

+ (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)sourceType;
+ (NSArray *)availableMediaTypesForSourceType:(UIImagePickerControllerSourceType)sourceType;

+ (BOOL)isCameraDeviceAvailable:(UIImagePickerControllerCameraDevice)cameraDevice;
+ (BOOL)isFlashAvailableForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;
+ (NSArray *)availableCaptureModesForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;

@property(nonatomic,assign)    id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate;

@property(nonatomic)           UIImagePickerControllerSourceType     sourceType;
@property(nonatomic,copy)      NSArray                              *mediaTypes;
@property(nonatomic)           BOOL                                  allowsEditing;
@property(nonatomic)           BOOL                                  allowsImageEditing;// NS_DEPRECATED_IOS(2_0, 3_1);

// video properties apply only if mediaTypes includes kUTTypeMovie
@property(nonatomic)           NSTimeInterval                        videoMaximumDuration; // default value is 10 minutes.
@property(nonatomic)           UIImagePickerControllerQualityType    videoQuality;

@property(nonatomic)           BOOL                                  showsCameraControls;
@property(nonatomic,retain)    UIView                                *cameraOverlayView;
@property(nonatomic)           CGAffineTransform                     cameraViewTransform;

- (void)takePicture;
- (BOOL)startVideoCapture;
- (void)stopVideoCapture;

@property(nonatomic) UIImagePickerControllerCameraCaptureMode cameraCaptureMode;
@property(nonatomic) UIImagePickerControllerCameraDevice      cameraDevice ;
@property(nonatomic) UIImagePickerControllerCameraFlashMode   cameraFlashMode;


@end

@protocol UIImagePickerControllerDelegate<NSObject>
@optional
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;// NS_DEPRECATED_IOS(2_0, 3_0);
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end


UIKIT_EXTERN void UIImageWriteToSavedPhotosAlbum(UIImage *image, id completionTarget, SEL completionSelector, void *contextInfo);
UIKIT_EXTERN BOOL UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(NSString *videoPath);
UIKIT_EXTERN void UISaveVideoAtPathToSavedPhotosAlbum(NSString *videoPath, id completionTarget, SEL completionSelector, void *contextInfo);
