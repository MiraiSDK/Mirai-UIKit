//
//  TNSearchBarTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/6/24.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNSearchBarTestViewController.h"
#import "TNSearchBarDelegateTest.h"
#import "TNViewItemMaker.h"
#import "TNChangedColorButton.h"
#import "TNTargetActionToBlock.h"
#import "TNTitleChangedButton.h"

@implementation TNSearchBarTestViewController
{
    UISearchBar *_searchBar;
    NSMutableArray *_actionBlockContainer;
}

+ (NSString *)testName
{
    return @"UISearchBar Test";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_actionBlockContainer) {
        _actionBlockContainer = [NSMutableArray new];
    }
    [self _makeSearchBar];
    [self setViewControllers:@[[self _newButtonTestViewControoler],
                               [self _newScopeTestViewController],
                               [self _newDisplayTestViewController],
                               ]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)_makeSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 125, self.view.bounds.size.width, 75)];
    [self.view addSubview:_searchBar];
    
    TNSearchBarDelegateTest *searchBarDelegate = [[TNSearchBarDelegateTest alloc]init];
    _searchBar.delegate = searchBarDelegate;
    [_actionBlockContainer addObject:searchBarDelegate];
}

- (UIViewController *)_newButtonTestViewControoler
{
    UIViewController *buttonTestViewController = [self _newViewControllerWithTitle:@"button test"];
    TNViewItemMaker *maker = [self _newViewItemMakerWithViewController:buttonTestViewController];
    
    [self addProperty:@"showsBookmarkButton" forMaker:maker];
    [self addProperty:@"showsCancelButton" forMaker:maker];
    [self addProperty:@"showsSearchResultsButton" forMaker:maker];
    [self addProperty:@"searchResultsButtonSelected" forMaker:maker];
    
    return buttonTestViewController;
}

- (void)addProperty:(NSString *)property forMaker:(TNViewItemMaker *)maker
{
    __weak UISearchBar *weakSearchBar = _searchBar;
    
    TNTargetActionToBlock *actionBlock = [[TNTargetActionToBlock alloc] initWithBlock:^(UISwitch *switchItem) {
        [weakSearchBar setValue:@(switchItem.on) forKey:property];
    }];
    [_actionBlockContainer addObject:actionBlock];
    
    [maker makeItem:property block:^UIView *{
        UISwitch *switchItem = [[UISwitch alloc] initWithFrame:CGRectZero];
        NSNumber *onNumber = [_searchBar valueForKey:property];
        switchItem.on = [onNumber boolValue];
        [switchItem addTarget:actionBlock action:TNAction forControlEvents:UIControlEventValueChanged];
        return switchItem;
    }];
}

- (UIViewController *)_newScopeTestViewController
{
    UIViewController *scopeTestViewController = [self _newViewControllerWithTitle:@"scope test"];
    TNViewItemMaker *maker = [[TNViewItemMaker alloc] initWithView:scopeTestViewController.view];
    maker.topLocation = CGRectGetMaxY(_searchBar.frame) + 40;
    
    NSArray *scopeNameList = @[@"letter", @"number", @"name"];
    NSArray *scopeButtonTitlesList = @[@[@"A", @"B", @"C", @"D"],
                                       @[@"1", @"2", @"3", @"4"],
                                       @[@"Tom", @"Jerry"],
                                       ];
    
    [maker makeItem:@"scopeButtonTitles" block:^UIView *{
        __weak UISearchBar *weakSearchBar = _searchBar;
        TNTitleChangedButton *button = [[TNTitleChangedButton alloc]initWithTitles:scopeNameList withTappedBlock:^(NSString *title, NSUInteger index) {
            weakSearchBar.scopeButtonTitles = [scopeButtonTitlesList objectAtIndex:index];
        }];
        return button;
    }];
    [maker makeItem:@"selectedScopeButtonIndex" block:^UIView *{
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        
        __weak UIButton *weakButton = button;
        __weak UISearchBar *weakSearchBar = _searchBar;
        
        TNTargetActionToBlock *target = [[TNTargetActionToBlock alloc] initWithBlock:^(id sender) {
            NSString *title = [[NSString alloc] initWithFormat:@"refresh:%li",
                               weakSearchBar.selectedScopeButtonIndex];
            [weakButton setTitle:title forState:UIControlStateNormal];
        }];
        [_actionBlockContainer addObject:target];
        
        [button setTitle:@"show" forState:UIControlStateNormal];
        [button addTarget:target action:TNAction forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    }];
    [maker makeItem:@"showsScopeBar" block:^UIView *{
        UISwitch *switchItem = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchItem.on = _searchBar.showsScopeBar;
        
        __weak UISwitch *weakSwitch = switchItem;
        __weak UISearchBar *weakSearchBar = _searchBar;
        
        TNTargetActionToBlock *target = [[TNTargetActionToBlock alloc] initWithBlock:^(id sender) {
            weakSearchBar.showsScopeBar = weakSwitch.on;
        }];
        [_actionBlockContainer addObject:target];
        
        [switchItem addTarget:target action:TNAction forControlEvents:UIControlEventValueChanged];
        return switchItem;
    }];
    return scopeTestViewController;
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
        switchItem.on = _searchBar.translucent;
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
