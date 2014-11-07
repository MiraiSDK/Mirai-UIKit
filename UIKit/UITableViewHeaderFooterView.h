//
//  UITableViewHeaderFooterView.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIView.h>
#import <UIKit/UITableView.h>

@interface UITableViewHeaderFooterView : UIView
@property (nonatomic, retain) UIColor *tintColor;

@property (nonatomic, readonly, retain) UILabel *textLabel;
@property (nonatomic, readonly, retain) UILabel *detailTextLabel;

@property (nonatomic, readonly, retain) UIView *contentView;
@property (nonatomic, retain) UIView *backgroundView;

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)prepareForReuse;

@end
