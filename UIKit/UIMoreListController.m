//
//  UIMoreListController.m
//  UIKit
//
//  Created by TaoZeyu on 15/4/10.
//  Copyright (c) 2015年 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIMoreListController.h"
#import "UITableView.h"
#import "UITableViewCell.h"

@implementation UIMoreListController

- (instancetype)init
{
    if (self = [super init]) {
        _viewControllers = @[];
    }
    return self;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self _getCellWithTableView:tableView];
    UIViewController *controller = [self.viewControllers objectAtIndex:indexPath.row];
    [cell.textLabel setText:controller.title];
    return cell;
}

- (UITableViewCell *)_getCellWithTableView:(UITableView *)tableView
{
    NSString *identifier = @"UIMoreListControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

@end
