//
//  NSTextAttachment.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

enum {
    NSAttachmentCharacter = 0xFFFC // Replacement character is used for attachments
};

@class NSTextContainer;
@class UIImage;

@protocol NSTextAttachmentContainer <NSObject>

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex;

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex;

@end

@interface NSTextAttachment : NSObject <NSTextAttachmentContainer, NSCoding>
- (instancetype)initWithData:(NSData *)contentData ofType:(NSString *)uti;

@property(retain, nonatomic) NSData *contents;
@property(retain, nonatomic) NSString *fileType;

//@property(retain, nonatomic) NSFileWrapper *fileWrapper;

@property(retain, nonatomic) UIImage *image;

@property(nonatomic) CGRect bounds;

@end

@interface NSAttributedString (NSAttributedStringAttachmentConveniences)
+ (NSAttributedString *)attributedStringWithAttachment:(NSTextAttachment *)attachment;
@end

