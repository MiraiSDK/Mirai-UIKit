//
//  TNScrollViewContentInsetTestViewController.m
//  UIKitDemo
//
//  Created by Chen Yonghui on 4/20/15.
//  Copyright (c) 2015 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNScrollViewContentInsetTestViewController.h"

@interface TNScrollViewContentInsetTestViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation TNScrollViewContentInsetTestViewController

+ (NSString *)testName
{
    return @"ContentInsert";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    CGSize size =  self.view.bounds.size;
    size.width *=2;
    size.height *= 2;
    scrollView.contentSize = size;
    scrollView.pagingEnabled = YES;
    scrollView.contentInset = UIEdgeInsetsMake(0, width, 0, 0);
    
    CGRect contentRect = {CGPointZero,size};
    CGRect scrollingRect = UIEdgeInsetsInsetRect(contentRect, scrollView.contentInset);
    NSLog(@"set contentInset:%@",NSStringFromUIEdgeInsets(scrollView.contentInset));
    NSLog(@"contentRect:%@ scrollingRect:%@",NSStringFromCGRect(contentRect),NSStringFromCGRect(scrollingRect));

    
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(-width, 0, width, width)];
    left.backgroundColor =[UIColor redColor];
    [scrollView addSubview:left];
    
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    content.backgroundColor =[UIColor greenColor];
    [scrollView addSubview:content];
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(width, 0, width, width)];
    right.backgroundColor =[UIColor blueColor];
    [scrollView addSubview:right];


    scrollView.delegate = self;
    self.scrollView = scrollView;
    [self.view addSubview:self.scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    NSLog(@"%s contentOffset:%@",__PRETTY_FUNCTION__, NSStringFromCGPoint(scrollView.contentOffset));
}
@end
