//
//  TNScrollViewPagingTestViewController.m
//  BasicCairo
//
//  Created by Chen Yonghui on 8/27/14.
//  Copyright (c) 2014 Shanghai Tinynetwork. All rights reserved.
//

#import "TNScrollViewPagingTestViewController.h"

@interface TNScrollViewPagingTestViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, assign,getter=isVertical) BOOL vertical;
@end

@implementation TNScrollViewPagingTestViewController

- (void)dealloc
{
    _scrollView.delegate = nil;
}

+ (NSString *)testName
{
    return @"paging";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageCount = 8;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = [self contentSizeForViewSize:self.view.bounds.size];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    
    scrollView.layer.borderWidth = 2;
    scrollView.layer.borderColor = [UIColor redColor].CGColor;
    self.scrollView = scrollView;

    [self.view addSubview:scrollView];
    
    NSMutableArray *contents = [NSMutableArray array];
    for (int idx=0; idx<self.pageCount; idx++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [contents addObject:view];
        [scrollView addSubview:view];
    }
    self.contents = contents;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"direction" style:UIBarButtonItemStylePlain target:self action:@selector(changeDirection:)];
    self.navigationItem.rightBarButtonItems = @[item];
    
    [self configureScrollViewContents];
    
}

- (void)changeDirection:(id)sender
{
    self.vertical = !self.isVertical;
    
    [self configureScrollViewContents];
}

- (CGSize)contentSizeForViewSize:(CGSize)size
{
    if (self.isVertical) {
        return CGSizeMake(size.width, size.height * self.pageCount);
    }
    return CGSizeMake(size.width * self.pageCount, size.height);
}

- (void)configureScrollViewContents
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = [self contentSizeForViewSize:self.view.bounds.size];

    for (int idx = 0; idx < self.pageCount; idx++) {
        UIView *view = self.contents[idx];
        CGRect r;
        if (self.isVertical) {
            r = CGRectMake(0 , height * idx, width, height);
        } else {
            r = CGRectMake(width * idx , 0, width, height);
        }
        view.frame = r;
        CGFloat h = idx/(float)self.pageCount;
        view.backgroundColor = [UIColor colorWithHue:h saturation:1 brightness:1 alpha:1];
    }
    
}

- (void)viewWillLayoutSubviews
{
    [self configureScrollViewContents];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
@end
