//
//  UISearchController.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISearchController.h"
#import "UIView+UIPrivate.h"

#define kSearchBarHeightWhenActive 70

@interface _UISearchResultsViewContainer : UIView

@property (nonatomic) BOOL dimsBackgroundDuringPresentation;
@property (nonatomic) BOOL showResultsView;

- (instancetype)initWithSearchController:(UISearchController *)searchController;
- (void)setResultsView:(UIView *)resultsView;

@end

@interface _UISearchBarContainer : UIView

@property (nonatomic, readonly) UINavigationController *originalNavigationController;

- (instancetype)initWithSearchBar:(UISearchBar *)searchBar;
- (void)receiveSearchBarToThisContainer;
- (void)restoreSearchBarBack;

@end

static void SetViewAutoresizeToMatchSuperview(UIView *view) {
    view.frame = [UIScreen mainScreen].bounds; // delete this line after test.
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
                            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin |
                            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

@implementation UISearchController
{
    _UISearchResultsViewContainer *_searchResultsViewContainer;
    _UISearchBarContainer *_searchBarContainer;
    
    UIWindow *_searchResultsContainerWindow;
    BOOL _hasHideNavigationBar;
}

- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController
{
    if (self = [super init]) {
        _active = NO;
        _dimsBackgroundDuringPresentation = YES;
        _hidesNavigationBarDuringPresentation = YES;
        _searchResultsController = searchResultsController;
        
        // user may get searchBar before call [self view].
        // so, I have to create it on init method instead of loadView method.
        _searchBar = [[UISearchBar alloc] init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    SetViewAutoresizeToMatchSuperview(self.view);
    _searchResultsViewContainer = [self _newSearchResultsViewContainer];
    _searchBarContainer = [self _newSearchBarContainer];
    _searchResultsContainerWindow = [self _newSearchResultsContainerWindow];
}

- (_UISearchResultsViewContainer *)_newSearchResultsViewContainer
{
    _UISearchResultsViewContainer *searchResultsViewContainer = [[_UISearchResultsViewContainer alloc] initWithSearchController:self];
    [self.view addSubview:searchResultsViewContainer];
    if (_searchResultsController) {
        [searchResultsViewContainer setResultsView:_searchResultsController.view];
    }
    return searchResultsViewContainer;
}

- (_UISearchBarContainer *)_newSearchBarContainer
{
    _UISearchBarContainer *searchBarContainer = [[_UISearchBarContainer alloc] initWithSearchBar:_searchBar];
    [self.view addSubview:searchBarContainer];
    return searchBarContainer;
}

- (UIWindow *)_newSearchResultsContainerWindow
{
    UIWindow *searchResultsContainerWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [searchResultsContainerWindow setRootViewController:self];
    return searchResultsContainerWindow;
}

- (void)setSearchResultsController:(UIViewController *)searchResultsController
{
    if (_searchResultsController == searchResultsController) {
        return;
    }
    _searchResultsController = searchResultsController;
    UIView *resultsView = searchResultsController ? searchResultsController.view : nil;
    [_searchResultsViewContainer setResultsView:resultsView];
}

- (void)setDimsBackgroundDuringPresentation:(BOOL)dimsBackgroundDuringPresentation
{
    _dimsBackgroundDuringPresentation = dimsBackgroundDuringPresentation;
    _searchResultsViewContainer.dimsBackgroundDuringPresentation = dimsBackgroundDuringPresentation;
}

- (void)setActive:(BOOL)active
{
    if (_active == active) {
        return;
    }
    _active = active;
    _searchResultsContainerWindow.hidden = !active;
    
    if (active) {
        [self _doActive];
    } else {
        [self _doInactive];
    }
}

- (void)_doActive
{
    [self _moveSearchBarContainerToActiveLocation];
    [_searchBar setShowsCancelButton:YES];
    [_searchBarContainer receiveSearchBarToThisContainer];
    [self _playHideNavigationAnimationIfNeed];
}

- (void)_doInactive
{
    [_searchBar setShowsCancelButton:NO];
    [_searchBarContainer restoreSearchBarBack];
    [self recoverHidedNavigationBarIfNeed];
}

- (void)_moveSearchBarContainerToActiveLocation
{
    CGRect activeFrame;
    if (_searchBar.superview) {
        activeFrame = [self _frameOnRootParentWithView:_searchBar];
        
    } else {
        activeFrame = CGRectMake(0, 0,
                                 _searchResultsContainerWindow.bounds.size.width, kSearchBarHeightWhenActive);
    }
    _searchBarContainer.frame = activeFrame;
}

- (void)_playHideNavigationAnimationIfNeed
{
    if (!_dimsBackgroundDuringPresentation) {
        return;
    }
    UINavigationController *navigationController = _searchBarContainer.originalNavigationController;
    
    if (!navigationController || navigationController.navigationBarHidden) {
        return;
    }
    static CGFloat navigationHiddenDuration = 0.25;
    CGRect newSearchBarContainerFrame = _searchBarContainer.frame;
    newSearchBarContainerFrame.origin.y -= navigationController.navigationBar.bounds.size.height;
    
    NSLog(@"UISearchController play hide navigation bar animation.");
    _hasHideNavigationBar = YES;
    
    [navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:navigationHiddenDuration animations:^{
        _searchBarContainer.frame = newSearchBarContainerFrame;
    }];
}

- (void)recoverHidedNavigationBarIfNeed
{
    if (!_hasHideNavigationBar) {
        return;
    }
    _hasHideNavigationBar = NO;
    
    UINavigationController *navigationController = _searchBarContainer.originalNavigationController;
    [navigationController setNavigationBarHidden:NO animated:YES];
}

- (UINavigationController *)_findNavigationControllerOfView:(UIView *)view
{
    while (!view._viewController) {
        if (view) {
            return nil;
        }
        view = view.superview;
    }
    return view._viewController.navigationController;
}

- (CGRect)_frameOnRootParentWithView:(UIView *)view
{
    return [view convertRect:view.bounds toView:view.window];
}

@end

@implementation _UISearchResultsViewContainer
{
    UISearchController *_searchController;
    UIView *_resultsView;
}

- (instancetype)initWithSearchController:(UISearchController *)searchController
{
    if (self = [super init]) {
        _searchController = searchController;
        SetViewAutoresizeToMatchSuperview(self);
        [self setDimsBackgroundDuringPresentation:searchController.dimsBackgroundDuringPresentation];
        [self _registerTappedEvent];
    }
    return self;
}

- (void)setDimsBackgroundDuringPresentation:(BOOL)dimsBackgroundDuringPresentation
{
    if (_dimsBackgroundDuringPresentation == dimsBackgroundDuringPresentation) {
        return;
    }
    _dimsBackgroundDuringPresentation = dimsBackgroundDuringPresentation;
    
    if (dimsBackgroundDuringPresentation) {
        [self setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)setShowResultsView:(BOOL)showResultsView
{
    _showResultsView = showResultsView;
    _resultsView.hidden = !showResultsView;
}

- (void)setResultsView:(UIView *)resultsView
{
    if (_resultsView) {
        [_resultsView removeFromSuperview];
    }
    _resultsView = resultsView;
    resultsView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    resultsView.hidden = !_showResultsView;
    
    SetViewAutoresizeToMatchSuperview(resultsView);
    [self addSubview:_resultsView];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (_dimsBackgroundDuringPresentation) {
        return hitView;
    } else {
        // can't hit this container self.
        return hitView == self? nil: hitView;
    }
}

- (void)_registerTappedEvent
{
    UITapGestureRecognizer *singletapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTappedSelf:)];
    [self addGestureRecognizer:singletapGestureRecognizer];
}

- (void)_onTappedSelf:(id)sender
{
    [_searchController setActive:NO];
}

@end

@implementation _UISearchBarContainer
{
    UISearchBar *_searchBar;
    UITableView *_originalSuperview;
    UIView *_placeholder;
    BOOL _isSearchBarReceivedInContainer;
}

- (instancetype)initWithSearchBar:(UISearchBar *)searchBar
{
    if (self = [super init]) {
        _searchBar = searchBar;
    }
    return self;
}

- (UINavigationController *)originalNavigationController
{
    return [self _findNavigationControllerOfView:(_placeholder ?: _searchBar)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_searchBar.superview == self) {
        _searchBar.frame = self.bounds;
    }
}

- (void)receiveSearchBarToThisContainer
{
    if (_isSearchBarReceivedInContainer) {
        return;
    }
    
    if (![_searchBar.superview isKindOfClass:UITableView.class]) {
        _searchBar.hidden = YES;
        _isSearchBarReceivedInContainer = YES;
        return;
    }
    _originalSuperview = (UITableView *)_searchBar.superview;
    _placeholder = [self _newPlaceholderOf:_searchBar];
    _isSearchBarReceivedInContainer = YES;
    
    if (_originalSuperview.tableHeaderView == _searchBar) {
        _originalSuperview.tableHeaderView = _placeholder;
        [self _addSearchBarAsChildAndSetFrame:_searchBar];
        
    } else if (_originalSuperview.tableFooterView == _searchBar) {
        _originalSuperview.tableFooterView = _placeholder;
        [self _addSearchBarAsChildAndSetFrame:_searchBar];
        
    } else {
        _originalSuperview = nil;
        _placeholder = nil;
        _isSearchBarReceivedInContainer = NO;
    }
}

- (void)restoreSearchBarBack
{
    if (!_isSearchBarReceivedInContainer) {
        return;
    }
    
    if (!_originalSuperview) {
        _searchBar.hidden = NO;
        _isSearchBarReceivedInContainer = NO;
        
    } else {
        _searchBar.frame = _placeholder.frame;
        _searchBar.autoresizingMask = _placeholder.autoresizingMask;
        
        if(_originalSuperview.tableHeaderView == _placeholder) {
            _originalSuperview.tableHeaderView = _searchBar;
            
        } else if (_originalSuperview.tableFooterView == _placeholder) {
            _originalSuperview.tableFooterView = _searchBar;
        }
        _placeholder = nil;
        _originalSuperview = nil;
        _isSearchBarReceivedInContainer = NO;
    }
}

- (UIView *)_newPlaceholderOf:(UISearchBar *)searchBar
{
    UIView *placeholder =  [[UIView alloc] initWithFrame:searchBar.frame];
    placeholder.autoresizingMask = searchBar.autoresizingMask;
    return placeholder;
}

- (void)_addSearchBarAsChildAndSetFrame:(UISearchBar *)searchBar
{
    searchBar.frame = self.bounds;
    searchBar.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:searchBar];
}

- (UINavigationController *)_findNavigationControllerOfView:(UIView *)view
{
    while (!view._viewController) {
        if (!view) {
            return nil;
        }
        view = view.superview;
    }
    return view._viewController.navigationController;
}

@end