//
//  NSTextContainer.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/NSParagraphStyle.h>
#import <UIKit/NSLayoutManager.h>

@interface NSTextContainer : NSObject <NSCoding, NSTextLayoutOrientationProvider>
- (instancetype)initWithSize:(CGSize)size; // designated initializer
@property(assign, nonatomic) NSLayoutManager *layoutManager;


@property(nonatomic) CGSize size;
@property(copy, nonatomic) NSArray *exclusionPaths;
@property(nonatomic) NSLineBreakMode lineBreakMode;


@property(nonatomic) CGFloat lineFragmentPadding;
@property(nonatomic) NSUInteger maximumNumberOfLines;


- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect atIndex:(NSUInteger)characterIndex writingDirection:(NSWritingDirection)baseWritingDirection remainingRect:(CGRect *)remainingRect;


@property(nonatomic) BOOL widthTracksTextView;
@property(nonatomic) BOOL heightTracksTextView;

@end
