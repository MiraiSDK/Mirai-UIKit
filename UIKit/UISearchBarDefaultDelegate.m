//
//  UISearchBarDefaultDelegate.m
//  UIKit
//
//  Created by TaoZeyu on 15/7/3.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UISearchBarDefaultDelegate.h"

@implementation UISearchBarDefaultDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText { }

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar { }

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar { }

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar { }

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar { }

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar { }

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar { }

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope { }

@end
