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
#import "UITapGestureRecognizer.h"

@interface UIMoreListController()
@property (nonatomic, weak) id selectIndexCallbackTarget;
@property SEL selectIndexCallbackAction;
@end

@implementation UIMoreListController

- (instancetype)init
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _viewControllers = @[];
    }
    return self;
}

- (void)setSelectIndexCallbackWithTarget:(id)target action:(SEL)action
{
    self.selectIndexCallbackTarget = target;
    self.selectIndexCallbackAction = action;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self _getCellWithTableView:tableView with:indexPath.row];
    UIViewController *controller = [self.viewControllers objectAtIndex:indexPath.row];
    [cell.textLabel setText:controller.title];
    return cell;
}

- (UITableViewCell *)_getCellWithTableView:(UITableView *)tableView with:(NSUInteger)index
{
    NSString *identifier = @"UIMoreListControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell addGestureRecognizer:[self _createTapGestureRecognizer]];
        cell.tag = index;
    }
    return cell;
}

- (UITapGestureRecognizer *)_createTapGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onClickCell:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    return tapGestureRecognizer;
}

- (void)_onClickCell:(id)sender
{
    NSUInteger selectedIndex = [self _getCellIndexFromEvent:sender];
    [self.selectIndexCallbackTarget performSelector:self.selectIndexCallbackAction
                                         withObject:[NSNumber numberWithUnsignedInteger:selectedIndex]];
}

-(NSUInteger)_getCellIndexFromEvent:(UIGestureRecognizer *)tapEvent
{
    CGPoint touchPoint = [tapEvent locationInView:self.view];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    return indexPath.row;
}

@end
