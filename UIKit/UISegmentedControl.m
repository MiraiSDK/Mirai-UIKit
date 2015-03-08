//
//  UISegmentedControl.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UISegmentedControl.h"
#import "UIButton.h"
#import "UIImage.h"
#import "math.h"

#define DefaultTintColor [UIColor blueColor]
#define DefaultBackgroundColor [UIColor whiteColor]

typedef enum{
    SegmentedTypeTitle,
    SegmentedTypeImage
} SegmentedType;

@interface UISegmentedControl()
@property (nonatomic, strong) NSMutableArray *segmentArray;
@property (nonatomic, strong) NSMutableArray *segmentTitleArray;
@property (nonatomic, strong) NSMutableArray *segmentWidthArray;
@property BOOL hasChangedSelectedSegmentIndexDuringTouch;
@end

@implementation UISegmentedControl

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 44)];
    if (self) {
        [self setDefaultMomentaryValue];
        [self _makeSegmentArray:items];
        [self _refreshSegmentFrame];
        self.tintColor = DefaultTintColor;
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor
{
    if ([_tintColor isEqual:tintColor]) {
        _tintColor = tintColor;
        [self _setAllSegmentedButtonsTintColor:tintColor];
    }
}

#pragma mark - segment container.

- (NSUInteger)numberOfSegments
{
    return [self.segmentArray count];
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    UIButton *segmentedButton = [self _createSegmentedButtonWithTilte:title];
    [self _setTitleSegmentedButton:segmentedButton tintColor:self.tintColor];
    [self _insertSegmenetedButton:segmentedButton title:title at:segment];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
    [self _removeSegmentAt:segment];
}

- (void)removeAllSegments
{
    while (self.numberOfSegments > 0) {
        [self removeSegmentAtIndex:self.numberOfSegments - 1 animated:NO];
    }
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    UIButton *segmentedTitleButton = [self _getSegmentedTitleButtonAtIndex:segment];
    [segmentedTitleButton setTitle:title forState:UIControlStateNormal];
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment
{
    return [[self _getSegmentedTitleButtonAtIndex:segment] titleForState:UIControlStateNormal];;
}

- (void)_makeSegmentArray:(NSArray *)items
{
    self.segmentArray = [[NSMutableArray alloc] init];
    self.segmentTitleArray = [[NSMutableArray alloc] init];
    self.segmentWidthArray = [[NSMutableArray alloc] init];
    for (NSUInteger i=0; i<items.count; ++i) {
        id target = [items objectAtIndex:i];
        [self _createAndSetSegmentElementsWithItemTarget:target
                                      andInsertToSegment:i];
    }
}

- (SegmentedType)_getSegmentedTypeForSegmentAtIndex:(NSUInteger)segment
{
    return ([self.segmentArray objectAtIndex:segment] == nil)? SegmentedTypeTitle: SegmentedTypeImage;
}

- (UIButton *)_getSegmentedTitleButtonAtIndex:(NSUInteger)segment
{
    if ([self _getSegmentedTypeForSegmentAtIndex:segment] != SegmentedTypeTitle) {
        return nil;
    }
    return (UIButton *)[self.segmentArray objectAtIndex:segment];
}

- (void)_createAndSetSegmentElementsWithItemTarget:(id)target andInsertToSegment:(NSUInteger)segment
{
    UIButton *segmentedButton = nil;
    NSString *title = nil;
    if ([target isKindOfClass:NSString.class]) {
        title = (NSString *)target;
        segmentedButton =  [self _createSegmentedButtonWithTilte:title];
    } else {
        //TODO: now, just implements basically appearance.
        segmentedButton = [self _createSegmentedButtonWithTilte:@"image"];
    }
    [self _insertSegmenetedButton:segmentedButton title:title at:segment];
}

- (UIButton *)_createSegmentedButtonWithTilte:(NSString *)title
{
    UIButton *segmentedButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [segmentedButton setTitle:title forState:UIControlStateNormal];
    [segmentedButton addTarget:self action:@selector(_onReleaseSegment:)
              forControlEvents:UIControlEventTouchUpInside];
    [segmentedButton addTarget:self action:@selector(_onPressSegment:)
              forControlEvents:UIControlEventTouchDown];
    return segmentedButton;
}

- (void)_insertSegmenetedButton:(UIButton *)segmentedButton title:(NSString *)title at:(NSUInteger)segment
{
    [self.segmentArray insertObject:segmentedButton atIndex:segment];
    [self.segmentTitleArray insertObject:title atIndex:segment];
    [self.segmentWidthArray insertObject:[NSNumber numberWithFloat:0.0] atIndex:segment];
    [self addSubview:segmentedButton];
}

- (void)_replaceSegmenetedButton:(UIButton *)segmentedButton title:(NSString *)title at:(NSUInteger)segment
{
    [(UIButton *)[self.segmentArray objectAtIndex:segment] removeFromSuperview];
    [self.segmentArray replaceObjectAtIndex:segment withObject:segmentedButton];
    [self.segmentTitleArray replaceObjectAtIndex:segment withObject:title];
    [self.segmentWidthArray replaceObjectAtIndex:segment withObject:[NSNumber numberWithFloat:0.0]];
    [self addSubview:segmentedButton];
}

- (void)_removeSegmentAt:(NSUInteger)segment
{
    [(UIButton *)[self.segmentArray objectAtIndex:segment] removeFromSuperview];
    [self.segmentArray removeObjectAtIndex:segment];
    [self.segmentTitleArray removeObjectAtIndex:segment];
    [self.segmentWidthArray removeObjectAtIndex:segment];
}

- (void)_setAllSegmentedButtonsTintColor:(UIColor *)color
{
    for (NSUInteger i=0; i<self.segmentArray.count; ++i) {
        UIButton *titleSegmentedButton = [self _getSegmentedTitleButtonAtIndex:i];
        if (titleSegmentedButton != nil) {
            [self _setTitleSegmentedButton:titleSegmentedButton tintColor:color];
        }
    }
}

- (void)_setTitleSegmentedButton:(UIButton *)titleSegmentedButton tintColor:(UIColor *)color
{
    titleSegmentedButton.tintColor = color;
    [titleSegmentedButton.layer setBorderColor:[color CGColor]];
}

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment
{
    [self.segmentWidthArray replaceObjectAtIndex:segment withObject:[NSNumber numberWithFloat:width]];
}

- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment
{
    return [(NSNumber *)[self.segmentWidthArray objectAtIndex:segment] floatValue];
}

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment
{
    [[self _getSegmentedTitleButtonAtIndex:segment] setEnabled:enabled];
}

- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment
{
    return [[self _getSegmentedTitleButtonAtIndex:segment] isEnabled];
}

#pragma mark - select segement.

- (void)setDefaultMomentaryValue
{
    self.momentary = NO;
}

- (void)_onPressSegment:(id)sender
{
    self.hasChangedSelectedSegmentIndexDuringTouch = NO;
    NSUInteger segment = [self _getIndexOfSegmentSender:sender];
    [self _setSegment:segment isSelected:YES];
    
    if (self.momentary) {
        [self _setSelectedSegmentIndexAndTriggerEvent:segment];
    }
}

- (void)_onReleaseSegment:(id)sender
{
    if (self.momentary && self.hasChangedSelectedSegmentIndexDuringTouch) {
        [self _setSegment:self.selectedSegmentIndex isSelected:NO];
    }
    
    if (!self.momentary && !self.hasChangedSelectedSegmentIndexDuringTouch) {
        NSUInteger segment = [self _getIndexOfSegmentSender:sender];
        [self _setSelectedSegmentIndexAndTriggerEvent:segment];
    }
}

- (void)_setSelectedSegmentIndexAndTriggerEvent:(NSUInteger)selectedIndex
{
    if (selectedIndex != self.selectedSegmentIndex) {
        [self _setSegment:self.selectedSegmentIndex isSelected:NO];
        self.selectedSegmentIndex = selectedIndex;
        self.hasChangedSelectedSegmentIndexDuringTouch = YES;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (NSUInteger)_getIndexOfSegmentSender:(id)sender
{
    for (NSUInteger i=0; i<[self.segmentArray count]; i++) {
        if (sender == [self.segmentArray objectAtIndex:i]) {
            return i;
        }
    }
    return -1;
}

- (void)_setSegment:(NSUInteger)segment isSelected:(BOOL)selected
{
    UIButton *segmentedButton = [self _getSegmentedTitleButtonAtIndex:segment];
    UIColor *backgroundColor = selected? self.tintColor: DefaultBackgroundColor;
    UIColor *titleColor = selected? DefaultBackgroundColor: self.tintColor;
    
    segmentedButton.backgroundColor = backgroundColor;
    [segmentedButton setTitleColor:titleColor forState:UIControlStateNormal];
}

#pragma mark - frame and segment size

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self _refreshSegmentFrame];
}

- (void)_refreshSegmentFrame
{
    NSArray *widthArray = self.segmentWidthArray;
    int zeroWidthSegmentCount = [self _countZeroWidthSegment];
    if (zeroWidthSegmentCount > 0) {
        CGFloat remainWidth = [self _countRemainWidth];
        widthArray = [self _replaceZeroWidthAsSuitableValue:widthArray
                                                remainWidth:remainWidth
                                      zeroWidthSegmentCount:zeroWidthSegmentCount];
    }
    [self _setAllSegmentFrameWithWidthArray:widthArray];
}

- (int)_countZeroWidthSegment
{
    int count = 0;
    for (NSUInteger i=0; i<[self.segmentWidthArray count]; ++i) {
        NSNumber *width = (NSNumber *)[self.segmentWidthArray objectAtIndex:i];
        if ([width floatValue] == 0) {
            count++;
        }
    }
    return count;
}

- (CGFloat)_countRemainWidth
{
    CGFloat remainWidth = self.frame.size.width;
    for (NSUInteger i=0; i<[self.segmentArray count]; i++) {
        NSNumber *width = (NSNumber *)[self.segmentWidthArray objectAtIndex:i];
        remainWidth -= [width floatValue];
    }
    return fminf(remainWidth, 0);
}

- (NSArray *)_replaceZeroWidthAsSuitableValue:(NSArray *)widthArray remainWidth:(CGFloat)remainWidth zeroWidthSegmentCount:(int)zeroWidthSegmentCount
{
    // Because I don't know how iOS adjust segment whose width is zero. So, I give a simple way to adjust widths.
    // Now, self.apportionsSegmentWidthsByContent will not affect zero-width-segment at all.
    NSMutableArray *suitableWidthArray = [[NSMutableArray alloc] initWithArray:widthArray];
    CGFloat widthForEachZeroSegment = remainWidth/zeroWidthSegmentCount;
    for (NSUInteger i=0; i<[suitableWidthArray count]; i++) {
        NSNumber *width = (NSNumber *)[suitableWidthArray objectAtIndex:i];
        if ([width floatValue] == 0) {
            [suitableWidthArray replaceObjectAtIndex:i
                                          withObject:[NSNumber numberWithFloat:widthForEachZeroSegment]];
        }
    }
    return suitableWidthArray;
}

- (void)_setAllSegmentFrameWithWidthArray:(NSArray *)widthArray
{
    CGFloat x = 0;
    CGFloat height = self.frame.size.height;
    for (NSUInteger i=0; i<[widthArray count]; i++) {
        NSNumber *width = (NSNumber *)[widthArray objectAtIndex:i];
        UIButton *segmentButton = (UIButton *)[self.segmentArray objectAtIndex:i];
        segmentButton.frame = CGRectMake(x, 0, [width floatValue], height);
        x += [width floatValue];
    }
}

#pragma mark -
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    return self;
}
@end
