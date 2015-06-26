//
//  UISearchBar.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISearchBar.h"
#import <UIKit/UIKit.h>

#define kSearchInputBackgroundHeight 40
#define kCompoentInterval 10
#define kCancelButtonWidth 100
#define kTinyIconButtonSize 35

@implementation UISearchBar
{
    BOOL _showsSearchTextField;
    
    UITextField *_searchTextField;
    UIControl *_searchInputBackground;
    UIButton *_rightOperateButton;
    UIButton *_cancelButton;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _setDefaultValuesForAllProperties];
        [self _makeAllSubcomponets];
        [self _refreshAllSubcomponentsOnStageState];
        [self _refreshAllComponentsLayout];
        [self _refreshRightOperateIcon];
        [self _refreshAllComponentsAppearance];
    }
    return self;
}

#pragma mark - make and refresh state.

- (void)_setDefaultValuesForAllProperties
{
    _barStyle = UIBarStyleDefault;
    _searchBarStyle = UISearchBarStyleDefault;
    _translucent = YES;
}

- (void)_makeAllSubcomponets
{
    _searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _searchInputBackground = [[UIControl alloc] initWithFrame:CGRectZero];
    _rightOperateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self addSubview:_searchInputBackground];
}

- (void)_refreshAllSubcomponentsOnStageState
{
    [self _setOnStageState:_showsSearchTextField forSubcomponent:_searchTextField
                 container:_searchInputBackground];
    [self _setOnStageState:[self _willShowsRightOperateButton]
           forSubcomponent:_rightOperateButton container:_searchInputBackground];
    [self _setOnStageState:_showsCancelButton forSubcomponent:_cancelButton container:self];
}

- (BOOL)_willShowsRightOperateButton
{
    if (_showsSearchTextField) {
        return YES;
    } else {
        return _showsBookmarkButton || _showsSearchResultsButton || _searchResultsButtonSelected;
    }
}

- (void)_setOnStageState:(BOOL)onStage forSubcomponent:(UIView *)component container:(UIView *)container
{
    if ([self _isOnStage:component] && !onStage) {
        [component removeFromSuperview];
    } else if (![self _isOnStage:component] && onStage) {
        [container addSubview:component];
    }
}

- (void)_refreshAllComponentsLayout
{
    CGFloat searchRightXLocation = [self _refreshCancelButtonLayoutThenReturnSearchRightXLocation];
    [self _refreshSearchInputBackgroundLayoutWithSpaceWidth:(searchRightXLocation - 0.0)];
    [self _refreshRightOperateButtonLayout];
    [self _refreshSearchTextFieldLayout];
}

- (CGFloat)_refreshCancelButtonLayoutThenReturnSearchRightXLocation
{
    if ([self _isOnStage:_cancelButton]) {
        CGFloat cancelButtonStartXLocation = self.bounds.size.width - kCancelButtonWidth - kCompoentInterval;
        _cancelButton.frame = CGRectMake(cancelButtonStartXLocation, [self _searchInputBackgroundTopYLocation],
                                         kCancelButtonWidth, kSearchInputBackgroundHeight);
        return cancelButtonStartXLocation;
    } else {
        return self.bounds.size.width;
    }
}

- (void)_refreshSearchInputBackgroundLayoutWithSpaceWidth:(CGFloat)spaceWidth
{
    _searchInputBackground.frame = CGRectMake(kCompoentInterval, [self _searchInputBackgroundTopYLocation],
                                              spaceWidth - 2*kCompoentInterval, kSearchInputBackgroundHeight);
}

- (void)_refreshRightOperateButtonLayout
{
    if (![self _isOnStage:_rightOperateButton]) {
        return;
    }
    CGFloat closeToBorderInterval = [self _rightOperateButtonCloseToBroderInterval];
    _rightOperateButton.frame = CGRectMake(_searchInputBackground.bounds.size.width -
                                           closeToBorderInterval - kTinyIconButtonSize, closeToBorderInterval,
                                           kTinyIconButtonSize, kTinyIconButtonSize);
}

- (void)_refreshSearchTextFieldLayout
{
    if (![self _isOnStage:_searchTextField]) {
        return;
    }
    CGFloat sapceForRightOperate = 0.0;
    if (![self _isOnStage:_rightOperateButton]) {
        CGFloat closeToBorderInterval = [self _rightOperateButtonCloseToBroderInterval];
        sapceForRightOperate = CGRectGetMinX(_rightOperateButton.frame) - closeToBorderInterval;
    }
    _searchTextField.frame = CGRectMake(0, 0,
                                        _searchInputBackground.bounds.size.width - sapceForRightOperate,
                                        _searchInputBackground.bounds.size.height);
}

- (CGFloat)_searchInputBackgroundTopYLocation
{
    return (self.bounds.size.height - kSearchInputBackgroundHeight)/2;
}

- (CGFloat)_rightOperateButtonCloseToBroderInterval
{
    return (_searchInputBackground.bounds.size.height - kTinyIconButtonSize)/2;
}

- (void)_refreshRightOperateIcon
{
    if ([self _isOnStage:_searchTextField]) {
        [_rightOperateButton setTitle:@"X" forState:UIControlStateNormal];
        
    } else {
        if (_showsSearchResultsButton && _searchResultsButtonSelected) {
            [_rightOperateButton setTitle:@"(√)" forState:UIControlStateNormal];
            
        } else if (_showsSearchResultsButton) {
            [_rightOperateButton setTitle:@"√" forState:UIControlStateNormal];
            
        } else if (_showsBookmarkButton) {
            [_rightOperateButton setTitle:@"书" forState:UIControlStateNormal];
        }
    }
}

- (void)_refreshAllComponentsAppearance
{
    self.backgroundColor = [UIColor grayColor];
    _searchInputBackground.backgroundColor = [UIColor whiteColor];
}

#pragma mark - properties setter and getter

- (void)setShowsBookmarkButton:(BOOL)showsBookmarkButton
{
    if (_showsBookmarkButton != showsBookmarkButton) {
        _showsBookmarkButton = showsBookmarkButton;
        [self _refreshAllSubcomponentsOnStageState];
        [self _refreshAllComponentsLayout];
        [self _refreshRightOperateIcon];
    }
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    [self setShowsCancelButton:showsCancelButton animated:NO];
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated
{
    if (_showsCancelButton != showsCancelButton) {
        _showsCancelButton = showsCancelButton;
        [self _refreshAllSubcomponentsOnStageState];
        [self _refreshAllComponentsLayout];
    }
}

- (void)setShowsSearchResultsButton:(BOOL)showsSearchResultsButton
{
    if (_showsSearchResultsButton != showsSearchResultsButton) {
        _showsSearchResultsButton = showsSearchResultsButton;
        [self _refreshAllSubcomponentsOnStageState];
        [self _refreshAllComponentsLayout];
        [self _refreshRightOperateIcon];
    }
}

- (void)setSearchResultsButtonSelected:(BOOL)searchResultsButtonSelected
{
    if (_searchResultsButtonSelected != searchResultsButtonSelected) {
        _searchResultsButtonSelected = searchResultsButtonSelected;
        [self _refreshAllSubcomponentsOnStageState];
        [self _refreshAllComponentsLayout];
        [self _refreshRightOperateIcon];
    }
}

#pragma mark - util methodes

- (BOOL)_isOnStage:(UIView *)subview
{
    return subview.superview != nil;
}

@end
