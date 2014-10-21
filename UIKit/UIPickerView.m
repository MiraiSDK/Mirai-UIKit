//
//  UIPickerView.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UIPickerView.h"
#import "NSStringDrawing.h"
#import "UIGraphics.h"
#import "UIColor.h"

@implementation UIPickerView
+ (BOOL)isUnimplemented
{
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (NSInteger)numberOfRowsInComponent:(NSInteger)component
{
    return 0;
}

- (CGSize)rowSizeForComponent:(NSInteger)component
{
    return CGSizeZero;
}

- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return nil;
}

- (void)reloadAllComponents
{
    
}

- (void)reloadComponent:(NSInteger)component
{
    
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{
    
}

- (NSInteger)selectedRowInComponent:(NSInteger)component
{
    return 0;
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    return self;
}

@end
