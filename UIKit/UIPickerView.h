//
//  UIPickerView.h
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIView.h>
#import <UIKit/UITableView.h>
#import <UIKit/UIKitDefines.h>

@protocol UIPickerViewDataSource, UIPickerViewDelegate;

@interface UIPickerView : UIView <NSCoding, UITableViewDataSource>
@property(nonatomic,assign) id<UIPickerViewDataSource> dataSource;                // default is nil. weak reference
@property(nonatomic,assign) id<UIPickerViewDelegate>   delegate;                  // default is nil. weak reference
@property(nonatomic)        BOOL                       showsSelectionIndicator;   // default is NO

@property(nonatomic,readonly) NSInteger numberOfComponents;
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;
- (CGSize)rowSizeForComponent:(NSInteger)component;

- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component;

- (void)reloadAllComponents;
- (void)reloadComponent:(NSInteger)component;

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
- (NSInteger)selectedRowInComponent:(NSInteger)component;

@end

@protocol UIPickerViewDataSource<NSObject>
@required
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
@end


@protocol UIPickerViewDelegate<NSObject>
@optional

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end
