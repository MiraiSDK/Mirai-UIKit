//
//  UISearchController.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISearchController.h"

@interface _UISearchResultsViewContainer : UIView

@property (nonatomic) BOOL dimsBackgroundDuringPresentation;
@property (nonatomic) BOOL showResultsView;

- (instancetype)initWithSearchController:(UISearchController *)searchController;
- (void)setResultsView:(UIView *)resultsView;

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
    UIWindow *_searchResultsContainerWindow;
}

- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController
{
    if (self = [super init]) {
        _active = NO;
        _dimsBackgroundDuringPresentation = YES;
        _hidesNavigationBarDuringPresentation = YES;
        _searchResultsController = searchResultsController;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    UIView *view = self.view;
    SetViewAutoresizeToMatchSuperview(view);
    
    _searchResultsViewContainer = [[_UISearchResultsViewContainer alloc] initWithSearchController:self];
    [view addSubview:_searchResultsViewContainer];
    if (_searchResultsController) {
        [_searchResultsViewContainer setResultsView:_searchResultsController.view];
    }
    
    _searchResultsContainerWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_searchResultsContainerWindow setRootViewController:self];
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