//
//  UISearchBar.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISearchBar.h"
#import <UIKit/UIKit.h>

#import "UITextField+UIPrivate.h"
#import "TNJavaBridgeProxy.h"

#define kSearchInputBackgroundHeight 18
#define kCompoentInterval 5
#define kCancelButtonWidth 80
#define kTinyIconButtonSize 17
#define kScopeBarHeight 20

typedef enum {
    UISearchBarRightOperateButtonStateClear,
    UISearchBarRightOperateButtonStateBookMark,
    UISearchBarRightOperateButtonStateSearchResult,
    UISearchBarRightOperateButtonStateSearchResultSelected,
} UISearchBarRightOperateButtonState;

@interface UISearchBar () <UITextFieldDelegate>
@end

@implementation UISearchBar
{
    UITextField *_searchTextField;
    UIControl *_searchInputBackground;
    UIButton *_rightOperateButton;
    UIButton *_cancelButton;
    UISegmentedControl *_scopeBar;
}

+ (void)initialize
{
    [UISearchBar _defineTextWatcher];
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
        [self _registerButtonTappedEventsForAll];
        [self _refreshAllSubcomponentsOnStageState];
        [self _refreshAllComponentsLayout];
        [self _refreshRightOperateIcon];
        [self _refreshAllComponentsAppearance];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _refreshAllComponentsLayout];
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
    
    _searchTextField.delegate = self;
    
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self _registerAllListenersToTextField:_searchTextField];
    
    [self addSubview:_searchInputBackground];
    [_searchInputBackground addSubview:_searchTextField];
}

- (UISegmentedControl *)_newScopeBar
{
    _selectedScopeButtonIndex = MIN(_selectedScopeButtonIndex, _scopeButtonTitles.count - 1);
    UISegmentedControl *scopeBar = [[UISegmentedControl alloc] initWithItems:_scopeButtonTitles];
    scopeBar.selectedSegmentIndex = _selectedScopeButtonIndex;
    [scopeBar addTarget:self action:@selector(_onSegmentedSelectedIndexChanged:)
       forControlEvents:UIControlEventValueChanged];
    return scopeBar;
}

- (void)_onSegmentedSelectedIndexChanged:(UISegmentedControl *)scopeBar
{
    if (_selectedScopeButtonIndex != scopeBar.selectedSegmentIndex) {
        _selectedScopeButtonIndex = scopeBar.selectedSegmentIndex;
        
        if ([_delegate respondsToSelector:@selector(searchBar:selectedScopeButtonIndexDidChange:)]) {
            [_delegate searchBar:self selectedScopeButtonIndexDidChange:_selectedScopeButtonIndex];
        }
    }
}

- (void)_refreshAllSubcomponentsOnStageState
{
    [self _setOnStageState:[self _willShowsRightOperateButton]
           forSubcomponent:_rightOperateButton container:_searchInputBackground];
    [self _setOnStageState:_showsCancelButton forSubcomponent:_cancelButton container:self];
    [self _synchronizeScopeOnStageState];
}

- (BOOL)_willShowsRightOperateButton
{
    if (![self _isSearchInputEmpty]) {
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

- (void)_synchronizeScopeOnStageState
{
    if ([self _willShowScopBar] && !_scopeBar) {
        _scopeBar = [self _newScopeBar];
        [self addSubview:_scopeBar];
        
    } else if (![self _willShowScopBar] && _scopeBar) {
        [_scopeBar removeFromSuperview];
        _scopeBar = nil;
    }
}

- (void)_refreshAllComponentsLayout
{
    CGFloat searchInputBackgroundTopLocation = [self _countSearchInputBackgroundTopLocationAndResizeSelf];
    CGFloat searchRightXLocation = [self _refreshCancelButtonLayoutThenReturnSearchRightXLocationWithTopLocation:searchInputBackgroundTopLocation];
    [self _refreshSearchInputBackgroundLayoutWithSpaceWidth:(searchRightXLocation - 0.0)
                                            withTopLocation:searchInputBackgroundTopLocation];
    [self _refreshRightOperateButtonLayout];
    [self _refreshSearchTextFieldLayout];
    [self _refreshScopeBarLayout];
}

- (CGFloat)_countSearchInputBackgroundTopLocationAndResizeSelf
{
    CGFloat contentHeight = kSearchInputBackgroundHeight;
    if (_scopeBar) {
        contentHeight += kScopeBarHeight + kCompoentInterval;
    }
    CGFloat selfMoreThanHeightOfContent = self.frame.size.height - contentHeight;
    if (selfMoreThanHeightOfContent < 0) {
        CGRect resizeFrame = self.frame;
        resizeFrame.size.height += ABS(selfMoreThanHeightOfContent);
        self.frame = resizeFrame;
        selfMoreThanHeightOfContent = 0;
    }
    return selfMoreThanHeightOfContent/2;
}

- (CGFloat)_refreshCancelButtonLayoutThenReturnSearchRightXLocationWithTopLocation:(CGFloat)topLocation
{
    if ([self _isOnStage:_cancelButton]) {
        CGFloat cancelButtonStartXLocation = self.bounds.size.width - kCancelButtonWidth - kCompoentInterval;
        _cancelButton.frame = CGRectMake(cancelButtonStartXLocation, topLocation,
                                         kCancelButtonWidth, kSearchInputBackgroundHeight);
        return cancelButtonStartXLocation;
    } else {
        return self.bounds.size.width;
    }
}

- (void)_refreshSearchInputBackgroundLayoutWithSpaceWidth:(CGFloat)spaceWidth
                                          withTopLocation:(CGFloat)topLocation
{
    _searchInputBackground.frame = CGRectMake(kCompoentInterval, topLocation,
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
    CGFloat sapceForRightOperate = 0.0;
    if (![self _isOnStage:_rightOperateButton]) {
        CGFloat closeToBorderInterval = [self _rightOperateButtonCloseToBroderInterval];
        sapceForRightOperate = CGRectGetMinX(_rightOperateButton.frame) - closeToBorderInterval;
    }
    _searchTextField.frame = CGRectMake(0, 0,
                                        _searchInputBackground.bounds.size.width - sapceForRightOperate,
                                        _searchInputBackground.bounds.size.height);
}

- (void)_refreshScopeBarLayout
{
    if (!_scopeBar) {
        return;
    }
    CGFloat topYLocation = CGRectGetMaxY(_searchInputBackground.frame);
    _scopeBar.frame = CGRectMake(kCompoentInterval, topYLocation + kCompoentInterval,
                                 self.frame.size.width - 2*kCompoentInterval, kScopeBarHeight);
}

- (CGFloat)_rightOperateButtonCloseToBroderInterval
{
    return (_searchInputBackground.bounds.size.height - kTinyIconButtonSize)/2;
}

- (void)_refreshRightOperateIcon
{
    NSString *title = nil;
    switch ([self _rightOperateButtonState]) {
        case UISearchBarRightOperateButtonStateClear:
            title = @"X";
            break;
        
        case UISearchBarRightOperateButtonStateSearchResultSelected:
            title = @"(√)";
            break;
        
        case UISearchBarRightOperateButtonStateSearchResult:
            title = @"√";
            break;
        
        case UISearchBarRightOperateButtonStateBookMark:
            title = @"书";
            break;
        
        default:
            break;
    }
    [_rightOperateButton setTitle:title forState:UIControlStateNormal];
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

- (void)setScopeButtonTitles:(NSArray *)scopeButtonTitles
{
    _scopeButtonTitles = scopeButtonTitles;
    [self _clearScopeBarIfExist];
    [self _refreshAllSubcomponentsOnStageState];
    [self _refreshAllComponentsLayout];
}

- (void)setShowsScopeBar:(BOOL)showsScopeBar
{
    if (_showsScopeBar != showsScopeBar) {
        _showsScopeBar = showsScopeBar;
        [self _refreshAllSubcomponentsOnStageState];
        [self _refreshAllComponentsLayout];
    }
}

- (void)_clearScopeBarIfExist
{
    if(_scopeBar) {
        [_scopeBar removeFromSuperview];
        _scopeBar = nil;
    }
}

- (NSString *)text
{
    return _searchTextField.text;
}

- (void)setText:(NSString *)text
{
    _searchTextField.text = text;
}

#pragma mark - Android EditText listener callback.

- (void)_registerAllListenersToTextField:(UITextField *)textFiled
{
    TNJavaBridgeProxy *textWatcherListener = [[TNJavaBridgeProxy alloc] initWithDefinition:_textWatcherListenerDefinition];
    [self _bindActionForTextWatcherLisenter:textWatcherListener];
    [textFiled setTextWatcherListener:textWatcherListener];
}

static TNJavaBridgeDefinition *_textWatcherListenerDefinition;

+ (void)_defineTextWatcher
{
    NSString *textWatcherClass = @"android.text.TextWatcher";
    NSArray *textWatcherSignatures = @[@"afterTextChanged(android.text.Editable)",
                                       @"beforeTextChanged(java.lang.CharSequence,int,int,int)",
                                       @"onTextChanged(java.lang.CharSequence,int,int,int)"];
    
    _textWatcherListenerDefinition = [[TNJavaBridgeDefinition alloc] initWithProxiedClassName:textWatcherClass
                                                                         withMethodSignatures:textWatcherSignatures];
}

- (void)_bindActionForTextWatcherLisenter:(TNJavaBridgeProxy *)textWatcherListener
{
    [textWatcherListener methodIndex:0 target:self action:@selector(_afterTextChanged:)];
    [textWatcherListener methodIndex:1 target:self action:@selector(_beforeTextChanged:)];
    [textWatcherListener methodIndex:2 target:self action:@selector(_onTextChanged:)];
}

- (void)_afterTextChanged:(TNJavaBridgeCallbackContext *)context
{
    [self _refreshAllSubcomponentsOnStageState];
    [self _refreshRightOperateIcon];
    [self _refreshAllComponentsLayout];
    
    if ([_delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [_delegate searchBar:self textDidChange:_searchTextField.text];
    }
}

- (void)_beforeTextChanged:(TNJavaBridgeCallbackContext *)context
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)_onTextChanged:(TNJavaBridgeCallbackContext *)context
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma about text field.

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [_delegate searchBarTextDidBeginEditing:self];
    }
}

- (BOOL)resignFirstResponder
{
    BOOL result = [super resignFirstResponder];
    [_searchTextField resignFirstResponder];
    return result;
}

#pragma mark - button callback

- (UISearchBarRightOperateButtonState)_rightOperateButtonState
{
    if (![self _isSearchInputEmpty]) {
        return UISearchBarRightOperateButtonStateClear;
        
    } else {
        if (_showsSearchResultsButton && _searchResultsButtonSelected) {
            return UISearchBarRightOperateButtonStateSearchResultSelected;
            
        } else if (_showsSearchResultsButton) {
            return UISearchBarRightOperateButtonStateSearchResult;
            
        } else if (_showsBookmarkButton) {
            return UISearchBarRightOperateButtonStateBookMark;
        }
    }
    return 0;
}

- (void)_registerButtonTappedEventsForAll
{
    [_cancelButton addTarget:self action:@selector(_onTappedCancelButton:)
            forControlEvents:UIControlEventTouchUpInside];
    [_rightOperateButton addTarget:self action:@selector(_onTappedRightOperateButton:)
                  forControlEvents:UIControlEventTouchUpInside];
}

- (void)_onTappedCancelButton:(id)sender
{
    if ([_delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [_delegate searchBarCancelButtonClicked:self];
    }
}

- (void)_onTappedRightOperateButton:(id)sender
{
    switch ([self _rightOperateButtonState]) {
        case UISearchBarRightOperateButtonStateClear:
            _searchTextField.text = @"";
            [self _refreshAllSubcomponentsOnStageState];
            [self _refreshAllComponentsLayout];
            [self _refreshRightOperateIcon];
            break;
        
        case UISearchBarRightOperateButtonStateSearchResultSelected:
            if ([_delegate respondsToSelector:@selector(searchBarResultsListButtonClicked:)]) {
                [_delegate searchBarResultsListButtonClicked:self];
            }
            break;
        
        case UISearchBarRightOperateButtonStateSearchResult:
            if ([_delegate respondsToSelector:@selector(searchBarResultsListButtonClicked:)]) {
                [_delegate searchBarResultsListButtonClicked:self];
            }
            break;
        
        case UISearchBarRightOperateButtonStateBookMark:
            if ([_delegate respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) {
                [_delegate searchBarBookmarkButtonClicked:self];
            }
            break;
        
        default:
            break;
    }
}

#pragma mark - util methodes

- (BOOL)_willShowScopBar
{
    return _showsScopeBar && _scopeButtonTitles;
}

- (BOOL)_isSearchInputEmpty
{
    return [_searchTextField.text isEqualToString:@""];
}

- (BOOL)_isOnStage:(UIView *)subview
{
    return subview != nil && subview.superview != nil;
}

@end
