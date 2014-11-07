//
//  UIStateRestoration.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

#pragma mark -- State Restoration Coder Keys --

UIKIT_EXTERN NSString *const UIStateRestorationViewControllerStoryboardKey;
UIKIT_EXTERN NSString *const UIApplicationStateRestorationBundleVersionKey;
UIKIT_EXTERN NSString *const UIApplicationStateRestorationUserInterfaceIdiomKey;
UIKIT_EXTERN NSString *const UIApplicationStateRestorationTimestampKey;
UIKIT_EXTERN NSString *const UIApplicationStateRestorationSystemVersionKey;

@class UIView;
@class UIViewController;

#pragma mark -- State Restoration protocols for UIView and UIViewController --

@protocol UIViewControllerRestoration
+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder;
@end

@protocol UIDataSourceModelAssociation
- (NSString *) modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view;
- (NSIndexPath *) indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view;
@end

#pragma mark -- State Restoration object protocols and methods --

@protocol UIObjectRestoration;

@protocol UIStateRestoring <NSObject>
@optional
@property (nonatomic, readonly) id<UIStateRestoring> restorationParent;
@property (nonatomic, readonly) Class<UIObjectRestoration> objectRestorationClass;

- (void) encodeRestorableStateWithCoder:(NSCoder *)coder;
- (void) decodeRestorableStateWithCoder:(NSCoder *)coder;

- (void) applicationFinishedRestoringState;
@end

@protocol UIObjectRestoration
+ (id<UIStateRestoring>) objectWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder;
@end

