//
//  TNSearchBarTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/24.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNSearchBarTestViewController.h"
#import "TNViewItemMaker.h"
#import "TNChangedColorButton.h"

@implementation TNSearchBarTestViewController
{
    UISearchBar *_searchBar;
}

+ (NSString *)testName
{
    return @"UISearchBar Test";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _makeSearchBar];
    [self setViewControllers:@[[self _newDisplayTestViewController]]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)_makeSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 75, self.view.bounds.size.width, 50)];
    [self.view addSubview:_searchBar];
}

- (UIViewController *)_newDisplayTestViewController
{
    UIViewController *displayTestViewController = [self _newViewControllerWithTitle:@"display test"];
    TNViewItemMaker *maker = [self _newViewItemMakerWithViewController:displayTestViewController];
    
    [maker makeItem:@"barStyle" block:^UIView *{
        NSArray *styles = @[@"Default", @"Black", @"BlackOpaque", @"BlackTranslucent"];
        UISegmentedControl *segmentedController = [[UISegmentedControl alloc] initWithItems:styles];
        [segmentedController addTarget:self action:@selector(_onDisplayStyleChanged:)
                      forControlEvents:UIControlEventValueChanged];
        return segmentedController;
    }];
    [maker makeItem:@"barTintColor" block:^UIView *{
        UIButton *button = [[TNChangedColorButton alloc] initWithFrame:CGRectZero
                                                      whenColorChanged:^(UIColor *color) {
            _searchBar.barTintColor = color;
        }];
        [button setTitle:@"change color" forState:UIControlStateNormal];
        return button;
    }];
    [maker makeItem:@"searchBarStyle" block:^UIView *{
        NSArray *styles = @[@"Default", @"Prominent", @"Minimal"];
        UISegmentedControl *segmentedController = [[UISegmentedControl alloc] initWithItems:styles];
        [segmentedController addTarget:self action:@selector(_onDisplaySearchBarStyleChanged:)
                      forControlEvents:UIControlEventValueChanged];
        return segmentedController;
    }];
    [maker makeItem:@"tintColor" block:^UIView *{
        UIButton *button = [[TNChangedColorButton alloc] initWithFrame:CGRectZero
                                                      whenColorChanged:^(UIColor *color) {
            _searchBar.tintColor = color;
        }];
        [button setTitle:@"change color" forState:UIControlStateNormal];
        return button;
    }];
    [maker makeItem:@"translucent" block:^UIView *{
        UISwitch *switchItem = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchItem addTarget:self action:@selector(_onDisplayTranslucentSwitchChanged:)
             forControlEvents:UIControlEventValueChanged];
        return switchItem;
    }];
    return displayTestViewController;
}

- (UIViewController *)_newViewControllerWithTitle:(NSString *)title
{
    UIViewController *viewViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    viewViewController.title = title;
    return viewViewController;
}

- (TNViewItemMaker *)_newViewItemMakerWithViewController:(UIViewController *)viewController
{
    TNViewItemMaker *maker = [[TNViewItemMaker alloc] initWithView:viewController.view];
    maker.topLocation = CGRectGetMaxY(_searchBar.frame);
    return maker;
}

- (void)_onDisplayStyleChanged:(UISegmentedControl *)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            _searchBar.barStyle = UIBarStyleDefault;
            break;
            
        case 1:
            _searchBar.barStyle = UIBarStyleBlack;
            break;
            
        case 2:
            _searchBar.barStyle = UIBarStyleBlackOpaque;
            break;
            
        case 3:
            _searchBar.barStyle = UIBarStyleBlackTranslucent;
            break;
            
        default:
            break;
    }
}

- (void)_onDisplaySearchBarStyleChanged:(UISegmentedControl *)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            _searchBar.searchBarStyle = UISearchBarStyleDefault;
            break;
            
        case 1:
            _searchBar.searchBarStyle = UISearchBarStyleProminent;
            break;
            
        case 2:
            _searchBar.searchBarStyle = UISearchBarStyleMinimal;
            break;
            
        default:
            break;
    }
}

- (void)_onDisplayTranslucentSwitchChanged:(UISwitch *)switchItem
{
    _searchBar.translucent = switchItem.on;
}

@end
