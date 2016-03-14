//
//  TNBezierPathTestViewController.m
//  UIKitDemo
//
//  Created by Chen Yonghui on 3/14/16.
//  Copyright © 2016 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNBezierPathTestViewController.h"

@interface TNBezierPathTestViewController ()

@end

@implementation TNBezierPathTestViewController

+ (void)load
{
    [self regisiterTestClass:self];
}

+ (NSString *)testName
{
    return @"UIBezierPath Test";
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 30)];
    label.text = @"Two Shapes at below should be same";
    [self.view addSubview:label];
    
    CGPoint point = CGPointMake(100, 100);
    CGPoint cp1 = CGPointMake(100, 0);
    CGPoint cp2 = CGPointMake(100, 100);
    
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, 130, 100, 100);
    shape.strokeColor = [UIColor blackColor].CGColor;
    shape.borderWidth =1;
    [self.view.layer addSublayer:shape];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, 100, 30)];
    l.text = @"UIBezierPath";
    [self.view addSubview:l];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addCurveToPoint:point controlPoint1:cp1 controlPoint2:cp2];
    shape.path = path.CGPath;
    
    CAShapeLayer *shape1 = [CAShapeLayer layer];
    shape1.frame = CGRectMake(110, 130, 100, 100);
    shape1.strokeColor = [UIColor blackColor].CGColor;
    shape1.borderWidth = 1;
    [self.view.layer addSublayer:shape1];
    UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(110, 240, 100, 30)];
    l1.text = @"CGPath";
    [self.view addSubview:l1];
    
    CGMutablePathRef p = CGPathCreateMutable();
    CGPathMoveToPoint(p, NULL, 0, 0);
    CGPathAddCurveToPoint(p, NULL, cp1.x, cp1.y, cp2.x, cp2.y, point.x, point.y);
    shape1.path = p;
}


@end
