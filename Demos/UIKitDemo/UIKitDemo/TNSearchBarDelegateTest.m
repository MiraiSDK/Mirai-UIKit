//
//  TNSearchBarDelegateTest.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/25.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNSearchBarDelegateTest.h"

@implementation TNSearchBarDelegateTest

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%s %@", __FUNCTION__, searchText);
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range
  replacementText:(NSString *)text
{
    NSLog(@"%s %@ %@", __FUNCTION__, NSStringFromRange(range), text);
    
    // to make sure this method valid.
    if (range.location + range.length > 15) {
        return NO;
    }
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"%s", __FUNCTION__);
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    NSLog(@"%s %l", __FUNCTION__, selectedScope, selectedScope);
}

@end
