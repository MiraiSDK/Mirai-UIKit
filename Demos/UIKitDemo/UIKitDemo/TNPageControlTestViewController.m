//
//  TNPageControlTestViewController.m
//  UIKitDemo
//
//  Created by TaoZeyu on 15/4/27.
//  Copyright (c) 2015年 Shanghai TinyNetwork Inc. All rights reserved.
//

#import "TNPageControlTestViewController.h"
#import "TNChangedColorButton.h"

@interface TNPageControlTestViewController ()
@property (nonatomic) NSInteger pageCount;
@property (nonatomic, readonly) NSUInteger currentPageIndex;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIPageControl* pageControl;
@end

@implementation TNPageControlTestViewController

+ (NSString *)testName
{
    return @"UIPageControl Test";
}

+ (void)load
{
    [self regisiterTestClass:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _makeScrollViewAndPageControl];
    [self _makeControlPanel];
    [self _settingSelfDefaultState];
}

+ (UIColor *)_getSubviewBackgroundColorAt:(NSUInteger)index
{
    static NSArray *colorArray = nil;
    if (colorArray == nil) {
        colorArray = @[
                       [UIColor redColor],
                       [UIColor orangeColor],
                       [UIColor yellowColor],
                       [UIColor greenColor],
                       [UIColor lightGrayColor],
                       [UIColor blueColor],
                       [UIColor purpleColor],
                       ];
    }
    index = index % colorArray.count;
    return [colorArray objectAtIndex:index];
}

#pragma mark - basically scroll page.

+ (UIColor *)_getSubviewTextColorAt:(NSUInteger)index
{
    static NSArray *colorArray = nil;
    if (colorArray == nil) {
        colorArray = @[
                       [UIColor whiteColor],
                       [UIColor whiteColor],
                       [UIColor blackColor],
                       [UIColor blackColor],
                       [UIColor blackColor],
                       [UIColor whiteColor],
                       [UIColor whiteColor],
                       ];
    }
    index = index % colorArray.count;
    return [colorArray objectAtIndex:index];
}

- (void)setPageCount:(NSInteger)pageCount
{
    if (_pageCount != pageCount) {
        _pageCount = pageCount;
        _pageControl.numberOfPages = pageCount;
        [self _refreshScrollViewContent];
    }
}

- (NSUInteger)currentPageIndex
{
    return _scrollView.contentOffset.x/_scrollView.bounds.size.width;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = self.currentPageIndex;
}

- (void)_makeScrollViewAndPageControl
{
    self.scrollView = [self _createScrollView];
    self.pageControl = [self _createPageControl];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];
}

- (void)_refreshScrollViewContent
{
    _scrollView.contentSize = CGSizeMake(_pageCount*self.view.bounds.size.width,
                                         self.view.bounds.size.height);
    [self _clearAllSubviewWithContainer:_scrollView];
    [self _makeContentForScrollView];
}

- (UIScrollView *)_createScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    return scrollView;
}

- (UIPageControl *)_createPageControl
{
    return [[UIPageControl alloc] initWithFrame:[self _getPageControlFrame]];
}

- (CGRect)_getPageControlFrame
{
    CGFloat bottomInterval = 40;
    CGSize pageControlSize = CGSizeMake(200, 50);
    return CGRectMake((self.view.bounds.size.width - pageControlSize.width)/2,
                      self.view.bounds.size.height - bottomInterval - pageControlSize.height,
                      pageControlSize.width, pageControlSize.height);
}

- (void)_clearAllSubviewWithContainer:(UIView *)container
{
    while (container.subviews.count > 0) {
        UIView *subview = [container.subviews objectAtIndex:0];
        [subview removeFromSuperview];
    }
}

- (void)_makeContentForScrollView
{
    for (NSUInteger i = 0; i < _pageCount; i++) {
        CGRect subarea = [self _getSubareaAt:i];
        UIView *subview = [self _createSubviewInArea:subarea withIndex:i];
        [_scrollView addSubview:subview];
    }
}

- (CGRect)_getSubareaAt:(NSUInteger)index
{
    CGSize boundsSize = self.view.bounds.size;
    return CGRectMake(index*boundsSize.width, 0, boundsSize.width, boundsSize.height);
}

- (UIView *)_createSubviewInArea:(CGRect)area withIndex:(NSUInteger)index
{
    UILabel *label = [[UILabel alloc] initWithFrame:[self _getCentreFrameWithSize:CGSizeMake(80, 50) inArea:area]];
    [label setText:[NSString stringWithFormat:@"view(%li)", index + 1]];
    label.textColor = [TNPageControlTestViewController _getSubviewTextColorAt:index];
    label.backgroundColor = [TNPageControlTestViewController _getSubviewBackgroundColorAt:index];
    
    UIView *rect = [[UIView alloc] initWithFrame:area];
    rect.backgroundColor = [TNPageControlTestViewController _getSubviewBackgroundColorAt:index];
    [rect addSubview:label];
    
    return rect;
}

- (CGRect)_getCentreFrameWithSize:(CGSize)size inArea:(CGRect)area
{
    return CGRectMake((area.size.width - size.width)/2,
                      (area.size.height - size.height)/2,
                      size.width, size.height);
}

#pragma mark - control panel.

- (void)_makeControlPanel
{
    UIView *controlPanel = [self _createControlPanelAndSettingAppearance];
    [self _addComponentsForControlPanel:controlPanel];
    [self.view addSubview:controlPanel];
}

- (void)_settingSelfDefaultState
{
    [self setPageCount:4];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (UIView *)_createControlPanelAndSettingAppearance
{
    CGSize boundsSize = self.view.bounds.size;
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(8, 108,
                                                             0.8*boundsSize.width, 0.3*boundsSize.height)];
    panel.layer.borderWidth = 2;
    panel.layer.borderColor = [UIColor blackColor].CGColor;
    panel.backgroundColor = [UIColor whiteColor];
    return panel;
}

- (void)_addComponentsForControlPanel:(UIView *)controlPanel
{
    UISegmentedControl *segmentedControl = [self _createPageNumberSegmentedControlAndAddTo:controlPanel
                                                                                atLocation:5];
    [segmentedControl addTarget:self action:@selector(_onPageNumberChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    UISwitch *hidesForSinglePageSwitch = [self _createSwitchAndAddTo:controlPanel atLocation:45];
    [hidesForSinglePageSwitch addTarget:self action:@selector(_onSwitchValueChanged:)
                       forControlEvents:UIControlEventValueChanged];
    
    [self _makeTintColorChangedButtonForProperty:@"pageIndicatorTintColor"
                               addToControlPanel:controlPanel at:85];
    [self _makeTintColorChangedButtonForProperty:@"currentPageIndicatorTintColor"
                               addToControlPanel:controlPanel at:115];
}

- (UISegmentedControl *)_createPageNumberSegmentedControlAndAddTo:(UIView *)controlPanel atLocation:(CGFloat)location
{
    NSArray *numberStringArray = [self _getNumberStringArrayWithLength:8];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:numberStringArray];
    segmentedControl.frame = CGRectMake(5, location, controlPanel.bounds.size.width - 10, 25);
    [controlPanel addSubview:segmentedControl];
    return segmentedControl;
}

- (NSArray *)_getNumberStringArrayWithLength:(NSUInteger)length
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < length; i ++) {
        [array addObject:[NSString stringWithFormat:@"(%li)", i]];
    }
    return array;
}

- (UISwitch *)_createSwitchAndAddTo:(UIView *)controlPanel atLocation:(CGFloat)location
{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, location, 165, 35)];
    textLabel.text = @"hidesForSinglePage:";
    [controlPanel addSubview:textLabel];
    
    UISwitch *switchBar = [[UISwitch alloc] initWithFrame:CGRectMake(5 + textLabel.bounds.size.width,
                                                                     location, 0, 0)];
    switchBar.on = _pageControl.hidesForSinglePage;
    [controlPanel addSubview:switchBar];
    return switchBar;
}

- (void)_makeTintColorChangedButtonForProperty:(NSString *)propertyName addToControlPanel:(UIView *)controlPanel at:(CGFloat)location
{
    UIPageControl *pageControl = _pageControl;
    CGRect frame = CGRectMake(5, location, 200, 25);
    TNChangedColorButton *button = [[TNChangedColorButton alloc] initWithFrame:frame
                                                              whenColorChanged:^(UIColor *color) {
        NSLog(@"change %@'s color to %@", propertyName, color);
        [pageControl setValue:color forKey:propertyName];
    }];
    [button setTitle:propertyName forState:UIControlStateNormal];
    [controlPanel addSubview:button];
}

- (void)_onPageNumberChanged:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment) {
        self.pageCount = segmentedControl.selectedSegmentIndex;
    }
}

- (void)_onSwitchValueChanged:(UISwitch *)switchBar
{
    _pageControl.hidesForSinglePage = switchBar.on;
}

@end
