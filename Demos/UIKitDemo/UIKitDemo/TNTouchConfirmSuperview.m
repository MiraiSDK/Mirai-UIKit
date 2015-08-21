//
//  TNTouchConfirmSuperview.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/8/19.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNTouchConfirmSuperview.h"

@interface _TNTouchConfirmSuperviewCustomView : UIView

@property (nonatomic, strong) NSString *mark;
- (instancetype)initWithMark:(NSString *)mark;

@end

@interface _TNTouchConfirmSuperviewShowLogView : _TNTouchConfirmSuperviewCustomView @end

@implementation TNTouchConfirmSuperview

+ (NSString *)testName
{
    return @"confirm superview";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIView *redView = [self _newViewWithEdgeInsets:UIEdgeInsetsMake(150, 45, 45, 45) mark:@"R"
                                         container:self.view color:[UIColor redColor] showLog:YES];
    UIView *blueView = [self _newViewWithEdgeInsets:UIEdgeInsetsMake(40, 40, 40, 40) mark:@"B"
                                          container:redView color:[UIColor blueColor] showLog:NO];
    UIView *greeenView = [self _newViewWithEdgeInsets:UIEdgeInsetsMake(40, 40, 40, 40) mark:@"G"
                                            container:blueView color:[UIColor greenColor] showLog:YES];
    
    UIView *centerView = [self _newViewWithEdgeInsets:UIEdgeInsetsMake(40, 40, 40, 40) mark:@"C"
                                            container:greeenView color:[UIColor whiteColor] showLog:NO];
}

- (UIView *)_newViewWithEdgeInsets:(UIEdgeInsets)edgeInsets mark:(NSString *)mark
                         container:(UIView *)container color:(UIColor *)color showLog:(BOOL)showLog
{
    UIView *view = nil;
    
//    showLog = YES;
    
    if (showLog) {
        view = [[_TNTouchConfirmSuperviewShowLogView alloc] initWithMark:mark];
    } else {
        view = [[_TNTouchConfirmSuperviewCustomView alloc] initWithMark:mark];
    }
    
    [container addSubview:view];
    [view setBackgroundColor:color];
    [view setFrame:UIEdgeInsetsInsetRect(container.bounds, edgeInsets)];
    return view;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"view controller's touchesBegan:withEvent callback.");
}

@end

@implementation _TNTouchConfirmSuperviewCustomView

- (instancetype)initWithMark:(NSString *)mark
{
    if (self = [self init]) {
        _mark = mark;
    }
    return self;
}


@end

@implementation _TNTouchConfirmSuperviewShowLogView


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _showTouchMessage:touches withPhase:@"began"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _showTouchMessage:touches withPhase:@"moved"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _showTouchMessage:touches withPhase:@"ended"];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _showTouchMessage:touches withPhase:@"cancelled"];
}

- (void)_showTouchMessage:(NSSet *)touches withPhase:(NSString *)phase
{
    NSString *viewMark = @"unknow";
    UITouch *touch = [touches anyObject];
    
    if (touch && [touch.view isKindOfClass:_TNTouchConfirmSuperviewCustomView.class]) {
        _TNTouchConfirmSuperviewCustomView *view = (_TNTouchConfirmSuperviewCustomView *)touch.view;
        viewMark = view.mark;
    }
    NSLog(@"[%@]-[%@] %@", self.mark, viewMark, phase);
}

@end