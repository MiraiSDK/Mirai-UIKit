//
//  TNSimultaneouselyGestureTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/9/15.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNSimultaneouselyGestureTestViewController.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface _TNTestSimultaneouselyGestureRecongizer : UITapGestureRecognizer
@property (nonatomic, strong) NSString *mark;
@property (nonatomic, assign) NSUInteger typeCode;
@end

@interface TNSimultaneouselyGestureTestViewController () <UIGestureRecognizerDelegate> @end

@implementation TNSimultaneouselyGestureTestViewController

+ (NSString *)testName
{
    return @"test behavior simultaneously gesture recognizer callback";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _TNTestSimultaneouselyGestureRecongizer *rec0 = [self _newTestGestureRecongizerWithMark:@"R-0"];
    _TNTestSimultaneouselyGestureRecongizer *rec1 = [self _newTestGestureRecongizerWithMark:@"R-1"];
    _TNTestSimultaneouselyGestureRecongizer *fail0 = [self _newTestGestureRecongizerWithMark:@"Fail-0"];
    _TNTestSimultaneouselyGestureRecongizer *fail1 = [self _newTestGestureRecongizerWithMark:@"Fail-1"];
    
    [self.view addGestureRecognizer:fail0];
    [self.view addGestureRecognizer:fail1];
    [self.view addGestureRecognizer:rec0];
    [self.view addGestureRecognizer:rec1];

    [fail0 requireGestureRecognizerToFail:rec0];
    [fail1 requireGestureRecognizerToFail:rec1];
    
    rec0.typeCode = 0;
    rec1.typeCode = 0;
    fail0.typeCode = 1;
    fail1.typeCode = 1;
    
    rec0.numberOfTapsRequired = 2;
    rec1.numberOfTapsRequired = 1;
}

- (_TNTestSimultaneouselyGestureRecongizer *)_newTestGestureRecongizerWithMark:(NSString *)mark
{
    _TNTestSimultaneouselyGestureRecongizer *recongizer = [[_TNTestSimultaneouselyGestureRecongizer alloc] init];
    recongizer.mark = mark;
    recongizer.delegate = self;
    [recongizer addTarget:self action:@selector(_onGestureAction:)];
    return recongizer;
}

- (BOOL)gestureRecognizer:(_TNTestSimultaneouselyGestureRecongizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(_TNTestSimultaneouselyGestureRecongizer *)otherGestureRecognizer
{
    if ([gestureRecognizer respondsToSelector:@selector(typeCode)] &&
        [otherGestureRecognizer respondsToSelector:@selector(typeCode)]) {
        
        return gestureRecognizer.typeCode == otherGestureRecognizer.typeCode;
    }
    return NO;
}

- (void)_onGestureAction:(_TNTestSimultaneouselyGestureRecongizer *)recongizer
{
    NSLog(@">> ------------------");
    NSLog(@">> action from %@", recongizer.mark);
    for (_TNTestSimultaneouselyGestureRecongizer *recongizer in self.view.gestureRecognizers) {
        NSLog(@"   %@'s state %zi", recongizer.mark, recongizer.state);
    }
    NSLog(@">> ------------------");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@">> viewcontroller recived %s", __FUNCTION__);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@">> viewcontroller recived %s", __FUNCTION__);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@">> viewcontroller recived %s", __FUNCTION__);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@">> viewcontroller recived %s", __FUNCTION__);
}

@end

@implementation _TNTestSimultaneouselyGestureRecongizer

- (void)reset
{
    [super reset];
    NSLog(@">> %@ reset", self.mark);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@">> %@ recive began", self.mark);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    NSLog(@">> %@ recive moved", self.mark);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSLog(@">> %@ recive ended", self.mark);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    NSLog(@">> %@ recive cancelled", self.mark);
}

@end