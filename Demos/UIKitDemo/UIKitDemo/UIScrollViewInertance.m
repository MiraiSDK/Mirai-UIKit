//
//  UIScrollViewInertance.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/8/12.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "UIScrollViewInertance.h"

@interface UIScrollViewInertance () <UIScrollViewDelegate> @end

@implementation UIScrollViewInertance
{
    CGFloat _lastContentOffset;
    NSDate *_lastCalledTime;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _lastCalledTime = [[NSDate alloc] init];
    }
    return self;
}

+ (NSString *)testName
{
    return @"UIScrollView Inertance Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 3000);
    scrollView.delegate = self;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(
                                     0, 0, scrollView.contentSize.width, scrollView.contentSize.height)];
    contentView.backgroundColor = [UIColor blueColor];
    [scrollView addSubview:contentView];
    [self.view addSubview:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat newContentOffset = scrollView.contentOffset.y;
    CGFloat distance = newContentOffset - _lastContentOffset;
    
    NSDate *newCalledTime = [[NSDate alloc] init];
    CGFloat costTime = newCalledTime.timeIntervalSince1970 - _lastCalledTime.timeIntervalSince1970;
    
    CGFloat speed = distance/costTime;
    
    _lastContentOffset = newContentOffset;
    _lastCalledTime = newCalledTime;
    
    NSLog(@"[SPEED] - %f =( %f )/( %f )", speed, distance ,costTime);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@" ");
    NSLog(@"[BeginDragging]");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"[EndDragging]");
    NSLog(@" ");
}

@end