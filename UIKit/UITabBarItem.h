//
//  UITabBarItem.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIBarItem.h>
#import <UIKit/UIGeometry.h>
#import <UIKit/UIKitDefines.h>

typedef NS_ENUM(NSInteger, UITabBarSystemItem) {
    UITabBarSystemItemMore,
    UITabBarSystemItemFavorites,
    UITabBarSystemItemFeatured,
    UITabBarSystemItemTopRated,
    UITabBarSystemItemRecents,
    UITabBarSystemItemContacts,
    UITabBarSystemItemHistory,
    UITabBarSystemItemBookmarks,
    UITabBarSystemItemSearch,
    UITabBarSystemItemDownloads,
    UITabBarSystemItemMostRecent,
    UITabBarSystemItemMostViewed,
};

@class UIView, UIImage;

@interface UITabBarItem : UIBarItem

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag;
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;
- (instancetype)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem tag:(NSInteger)tag;

@property(nonatomic,retain) UIImage *selectedImage;
@property (nonatomic) UIOffset titlePositionAdjustment;

@property(nonatomic,copy) NSString *badgeValue;    // default is nil

/*  These methods are now deprecated. Please use -initWithTitle:image:selectedImage:.
 */
- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage;// NS_DEPRECATED_IOS(5_0,7_0);
- (UIImage *)finishedSelectedImage;// NS_DEPRECATED_IOS(5_0,7_0);
- (UIImage *)finishedUnselectedImage;// NS_DEPRECATED_IOS(5_0,7_0);

- (void)setCallbackWhenNeedRefreshDisplayWithTarget:(id)target action:(SEL)action;
- (void)clearCallbackWhenNeedRefreshDisplay;

@end
