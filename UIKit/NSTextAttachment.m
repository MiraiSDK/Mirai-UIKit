//
//  NSTextAttachment.m
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "NSTextAttachment.h"

@implementation NSTextAttachment
- (instancetype)initWithData:(NSData *)contentData ofType:(NSString *)uti
{
    self = [super init];
    if (self) {
        _contents = contentData;
        _fileType = uti;
    }
    return self;
}

#pragma mark - NSTextAttachmentContainer
- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
    return nil;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    return CGRectZero;
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

@end
