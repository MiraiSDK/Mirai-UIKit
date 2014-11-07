//
//  NSTextStorage.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/NSAttributedString.h>

@class NSArray, NSLayoutManager;

@protocol NSTextStorageDelegate;

typedef NS_OPTIONS(NSUInteger, NSTextStorageEditActions) {
    NSTextStorageEditedAttributes = (1 << 0),
    NSTextStorageEditedCharacters = (1 << 1)
};

@interface NSTextStorage : NSMutableAttributedString
@property(readonly, nonatomic) NSArray *layoutManagers;
- (void)addLayoutManager:(NSLayoutManager *)aLayoutManager;
- (void)removeLayoutManager:(NSLayoutManager *)aLayoutManager;


/**************************** Pending edit info ****************************/
@property(nonatomic) NSTextStorageEditActions editedMask;
@property(nonatomic) NSRange editedRange;
@property(nonatomic) NSInteger changeInLength;


/**************************** Delegate ****************************/

@property(assign, nonatomic) id <NSTextStorageDelegate> delegate;


/**************************** Edit management ****************************/
- (void)edited:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta;
- (void)processEditing;


/**************************** Attribute fixing ****************************/
@property(readonly, nonatomic) BOOL fixesAttributesLazily;
- (void)invalidateAttributesInRange:(NSRange)range;
- (void)ensureAttributesAreFixedInRange:(NSRange)range;

@end
