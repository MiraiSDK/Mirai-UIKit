//
//  TNInteractiveImageWidgetTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/10/26.
//  Copyright © 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNInteractiveImageWidgetTestViewController.h"

@implementation TNInteractiveImageWidgetTestViewController
{
    BOOL _zoomIn;
    UIImageView *_imageView;
    UIScrollView *_scrollView;
}
+ (NSString *)testName
{
    return @"Interactive Image Widget";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"umaru.jpg"];
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(100, 260, image.size.width, image.size.height)];
    [_scrollView setBackgroundColor:[UIColor redColor]];
    [_scrollView addSubview:_imageView];
    [self.view addSubview:_scrollView];
    
    [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTapImage:)]];
    
    UIWindow *w0 = [[UIWindow alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    UIWindow *w1 = [[UIWindow alloc] initWithFrame:CGRectMake(20, 5, 100, 100)];
    
//    [w1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 2.0, 3.0)];
    
    NSLog(@"%@", NSStringFromCGPoint([w0 convertPoint:CGPointMake(45, 40) fromWindow:w1]));
    NSLog(@"%@", NSStringFromCGPoint([w0 convertPoint:CGPointMake(45, 40) fromView:w1]));
    NSLog(@"%@", NSStringFromCGPoint([w0 convertPoint:CGPointMake(45, 40) toWindow:w1]));
    NSLog(@"%@", NSStringFromCGPoint([w0 convertPoint:CGPointMake(45, 40) toView:w1]));
}

- (void)_onTapImage:(id)sender
{
    NSLog(@" ");
    NSLog(@"============");
    NSLog(@" %s", __FUNCTION__);
    NSLog(@"============");
    NSLog(@" ");
    
    _zoomIn = !_zoomIn;
    
    [UIView beginAnimations:@"scrollAnimation" context:NULL];
    [UIView setAnimationDuration:3.0];
    if (_zoomIn) {
        _scrollView.contentOffset = CGPointMake(80, 100);
        _imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } else {
        _scrollView.contentOffset = CGPointMake(0, 0);
        _imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    [UIView commitAnimations];
}

@end
