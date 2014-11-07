//
//  UISearchDisplayController.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UILabel.h>
#import <UIKit/UITableView.h>
#import <UIKit/UINavigationBar.h>

@class UISearchBar, UITableView, UIViewController, UIPopoverController;
@protocol UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate;

//NS_CLASS_DEPRECATED_IOS(3_0, 8_0, "UISearchDisplayController has been replaced with UISearchController")
@interface UISearchDisplayController : NSObject
- (instancetype)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController;

@property(nonatomic,assign)                           id<UISearchDisplayDelegate> delegate;

@property(nonatomic,getter=isActive)  BOOL            active;
- (void)setActive:(BOOL)visible animated:(BOOL)animated;

@property(nonatomic,readonly)                         UISearchBar                *searchBar;
@property(nonatomic,readonly)                         UIViewController           *searchContentsController;
@property(nonatomic,readonly)                         UITableView                *searchResultsTableView;
@property(nonatomic,assign)                           id<UITableViewDataSource>   searchResultsDataSource;
@property(nonatomic,assign)                           id<UITableViewDelegate>     searchResultsDelegate;
@property(nonatomic,copy)                             NSString                   *searchResultsTitle;

@property (nonatomic, assign) BOOL displaysSearchBarInNavigationBar;
@property (nonatomic, readonly) UINavigationItem *navigationItem;

@end
