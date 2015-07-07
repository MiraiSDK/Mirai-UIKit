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
- (instancetype)initWithSearchController:(UISearchController *)searchController;
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
        [self _settingDefaultValues];
        
        _searchResultsController = searchResultsController;
        _searchResultsViewContainer = [[_UISearchResultsViewContainer alloc] initWithSearchController:self];
        _searchResultsContainerWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        [_searchResultsContainerWindow setRootViewController:self];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    UIView *view = self.view;
    
    [view addSubview:_searchResultsViewContainer];
    view.backgroundColor = [UIColor redColor]; // delte it after test.
    SetViewAutoresizeToMatchSuperview(view);
}

- (void)_settingDefaultValues
{
    _active = NO;
    _dimsBackgroundDuringPresentation = YES;
    _hidesNavigationBarDuringPresentation = YES;
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
    
    NSLog(@"-> %@", NSStringFromCGRect(_searchResultsViewContainer.frame));
}

@end

@implementation _UISearchResultsViewContainer
{
    UISearchController *_searchController;
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