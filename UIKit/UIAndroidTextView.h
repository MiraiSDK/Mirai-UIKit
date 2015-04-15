//
//  UIAndroidTextView.h
//  UIKit
//
//  Created by Chen Yonghui on 4/5/15.
//  Copyright (c) 2015 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIAndroidTextView : UIView <UITextInputTraits>
@property (nonatomic, assign) UITextAlignment textAlignment; // stub, not yet implemented!
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
//@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;

- (void)setContentOffset:(CGPoint)theOffset;
- (void)scrollRangeToVisible:(NSRange)range;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;




@end
