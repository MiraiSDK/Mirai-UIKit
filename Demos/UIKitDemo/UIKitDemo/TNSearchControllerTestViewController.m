//
//  TNSearchControllerTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/7/6.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNSearchControllerTestViewController.h"
#import "TNUtils.h"

@interface TNSearchControllerTestViewController ()<UISearchControllerDelegate, UISearchResultsUpdating>

@end

@implementation TNSearchControllerTestViewController
{
    UISearchController *_searchController;
    UIViewController *_resultViewController;
    
    NSMutableArray *_actionBlockContainer;
    NSArray *_data;
}

+ (NSString *)testName
{
    return @"UISearchController Test";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _settingSelf];
    
    _resultViewController = [self _newResultViewController];
    _searchController = [self _newSearchController];
    
    [self _makePropertiesChangeSwitch];
    
    _searchController.searchBar.frame = CGRectMake(0, 0, 320, 44);
    self.tableView.tableHeaderView = _searchController.searchBar;
}

- (void)_settingSelf
{
    _actionBlockContainer = [[NSMutableArray alloc] init];
    _data = @[@"1", @"2", @"3"];
}

- (UISearchController *)_newSearchController
{
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:_resultViewController];
    
    searchController.delegate = self;
    searchController.searchResultsUpdater = self;
    searchController.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:0.3];
    
    return searchController;
}

- (UIViewController *)_newResultViewController
{
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:0.3];
    return vc;
}

- (void)_makePropertiesChangeSwitch
{
    TNViewItemMaker *maker = [[TNViewItemMaker alloc] initWithView:self.view];
    maker.topLocation = 200;
    
    [self addProperty:@"active" forMaker:maker];
    [self addProperty:@"definesPresentationContext" forMaker:maker];
    [self addProperty:@"dimsBackgroundDuringPresentation" forMaker:maker];
    [self addProperty:@"hidesNavigationBarDuringPresentation" forMaker:maker];
}

- (void)addProperty:(NSString *)property forMaker:(TNViewItemMaker *)maker
{
    __weak UISearchController *weakSearchController = _searchController;
    
    TNTargetActionToBlock *actionBlock = [[TNTargetActionToBlock alloc] initWithBlock:^(UISwitch *switchItem) {
        [weakSearchController setValue:@(switchItem.on) forKey:property];
    }];
    [_actionBlockContainer addObject:actionBlock];
    
    [maker makeItem:property block:^UIView *{
        UISwitch *switchItem = [[UISwitch alloc] initWithFrame:CGRectZero];
        NSNumber *onNumber = [_searchController valueForKey:property];
        switchItem.on = [onNumber boolValue];
        [switchItem addTarget:actionBlock action:TNAction forControlEvents:UIControlEventValueChanged];
        return switchItem;
    }];
}

#pragma mark - UITableViewController methods.

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}

#pragma mark - callback

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)presentSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __FUNCTION__);
}

@end
