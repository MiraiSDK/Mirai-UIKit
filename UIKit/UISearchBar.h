//
//  UISearchBar.h
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIInterface.h>
#import <UIKit/UIGeometry.h>
#import <UIKit/UITextField.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIBarButtonItem.h>
#import <UIKit/UIBarCommon.h>

typedef NS_ENUM(NSInteger, UISearchBarIcon) {
    UISearchBarIconSearch, // The magnifying glass
    UISearchBarIconClear, // The circle with an x in it
    UISearchBarIconBookmark, // The open book icon
    UISearchBarIconResultsList, // The list lozenge icon
};

typedef NS_ENUM(NSUInteger, UISearchBarStyle) {
    UISearchBarStyleDefault,    // currently UISearchBarStyleProminent
    UISearchBarStyleProminent,  // used my Mail, Messages and Contacts
    UISearchBarStyleMinimal     // used by Calendar, Notes and Music
};


@protocol UISearchBarDelegate;
@class UITextField, UILabel, UIButton, UIColor;

@interface UISearchBar : UIView
@property(nonatomic)        UIBarStyle              barStyle;              // default is UIBarStyleDefault (blue)
@property(nonatomic,assign) id<UISearchBarDelegate> delegate;              // weak reference. default is nil
@property(nonatomic,copy)   NSString               *text;                  // current/starting search text
@property(nonatomic,copy)   NSString               *prompt;                // default is nil
@property(nonatomic,copy)   NSString               *placeholder;           // default is nil
@property(nonatomic)        BOOL                    showsBookmarkButton;   // default is NO
@property(nonatomic)        BOOL                    showsCancelButton;     // default is NO
@property(nonatomic)        BOOL                    showsSearchResultsButton ;
@property(nonatomic, getter=isSearchResultsButtonSelected) BOOL searchResultsButtonSelected ;
- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated ;

@property(nonatomic,retain) UIColor *tintColor;
@property(nonatomic,retain) UIColor *barTintColor;
@property (nonatomic) UISearchBarStyle searchBarStyle;

@property(nonatomic,assign,getter=isTranslucent) BOOL translucent;

@property(nonatomic,copy) NSArray   *scopeButtonTitles;
@property(nonatomic)      NSInteger  selectedScopeButtonIndex;
@property(nonatomic)      BOOL       showsScopeBar;

@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;

@property(nonatomic,retain) UIImage *backgroundImage;
@property(nonatomic,retain) UIImage *scopeBarBackgroundImage;


- (void)setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)backgroundImageForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;


- (void)setSearchFieldBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state;
- (UIImage *)searchFieldBackgroundImageForState:(UIControlState)state;

- (void)setImage:(UIImage *)iconImage forSearchBarIcon:(UISearchBarIcon)icon state:(UIControlState)state;
- (UIImage *)imageForSearchBarIcon:(UISearchBarIcon)icon state:(UIControlState)state;

- (void)setScopeBarButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state;
- (UIImage *)scopeBarButtonBackgroundImageForState:(UIControlState)state;

- (void)setScopeBarButtonDividerImage:(UIImage *)dividerImage forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState;
- (UIImage *)scopeBarButtonDividerImageForLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState;

- (void)setScopeBarButtonTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state;
- (NSDictionary *)scopeBarButtonTitleTextAttributesForState:(UIControlState)state;

@property(nonatomic) UIOffset searchFieldBackgroundPositionAdjustment;

@property(nonatomic) UIOffset searchTextPositionAdjustment;

- (void)setPositionAdjustment:(UIOffset)adjustment forSearchBarIcon:(UISearchBarIcon)icon;
- (UIOffset)positionAdjustmentForSearchBarIcon:(UISearchBarIcon)icon;

@end

@protocol UISearchBarDelegate <UIBarPositioningDelegate>

@optional

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;                      // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;                     // called when text starts editing
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;                        // return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;                       // called when text ends editing
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text ;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;                     // called when keyboard search button pressed
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar;                   // called when bookmark button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;                     // called when cancel button pressed
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar;

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope ;

@end
