//
//  NSAttributedString.h
//  UIKit
//
//  Created by Chen Yonghui on 4/10/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>

UIKIT_EXTERN NSString *const NSFontAttributeName;
UIKIT_EXTERN NSString *const NSParagraphStyleAttributeName;
UIKIT_EXTERN NSString *const NSForegroundColorAttributeName;
UIKIT_EXTERN NSString *const NSBackgroundColorAttributeName;
UIKIT_EXTERN NSString *const NSLigatureAttributeName;
UIKIT_EXTERN NSString *const NSKernAttributeName;
UIKIT_EXTERN NSString *const NSStrikethroughStyleAttributeName;
UIKIT_EXTERN NSString *const NSUnderlineStyleAttributeName;
UIKIT_EXTERN NSString *const NSStrokeColorAttributeName;
UIKIT_EXTERN NSString *const NSStrokeWidthAttributeName;
UIKIT_EXTERN NSString *const NSShadowAttributeName;
UIKIT_EXTERN NSString *const NSTextEffectAttributeName;

UIKIT_EXTERN NSString *const NSAttachmentAttributeName;
UIKIT_EXTERN NSString *const NSLinkAttributeName;
UIKIT_EXTERN NSString *const NSBaselineOffsetAttributeName;
UIKIT_EXTERN NSString *const NSUnderlineColorAttributeName;
UIKIT_EXTERN NSString *const NSStrikethroughColorAttributeName;
UIKIT_EXTERN NSString *const NSObliquenessAttributeName;
UIKIT_EXTERN NSString *const NSExpansionAttributeName;

UIKIT_EXTERN NSString *const NSWritingDirectionAttributeName;
UIKIT_EXTERN NSString *const NSVerticalGlyphFormAttributeName;

typedef NS_ENUM(NSInteger, NSUnderlineStyle) {
    NSUnderlineStyleNone          = 0x00,
    NSUnderlineStyleSingle        = 0x01,
    NSUnderlineStyleThick         = 0x02,
    NSUnderlineStyleDouble        = 0x09,
    
    NSUnderlinePatternSolid       = 0x0000,
    NSUnderlinePatternDot         = 0x0100,
    NSUnderlinePatternDash        = 0x0200,
    NSUnderlinePatternDashDot     = 0x0300,
    NSUnderlinePatternDashDotDot  = 0x0400,
    
    NSUnderlineByWord             = 0x8000
};

typedef NS_ENUM(NSInteger, NSTextWritingDirection) {
    NSTextWritingDirectionEmbedding     = (0 << 1),
    NSTextWritingDirectionOverride      = (1 << 1)
};

UIKIT_EXTERN NSString *const NSTextEffectLetterpressStyle;

/************************ Attribute fixing ************************/

@interface NSMutableAttributedString (NSMutableAttributedStringKitAdditions)
- (void)fixAttributesInRange:(NSRange)range;
@end


/************************ Document formats ************************/

UIKIT_EXTERN NSString *const NSPlainTextDocumentType;
UIKIT_EXTERN NSString *const NSRTFTextDocumentType;
UIKIT_EXTERN NSString *const NSRTFDTextDocumentType;
UIKIT_EXTERN NSString *const NSHTMLTextDocumentType;

UIKIT_EXTERN NSString *const NSTextLayoutSectionOrientation;
UIKIT_EXTERN NSString *const NSTextLayoutSectionRange;

UIKIT_EXTERN NSString *const NSDocumentTypeDocumentAttribute;

UIKIT_EXTERN NSString *const NSCharacterEncodingDocumentAttribute;
UIKIT_EXTERN NSString *const NSDefaultAttributesDocumentAttribute;

UIKIT_EXTERN NSString *const NSPaperSizeDocumentAttribute;
UIKIT_EXTERN NSString *const NSPaperMarginDocumentAttribute;

UIKIT_EXTERN NSString *const NSViewSizeDocumentAttribute;
UIKIT_EXTERN NSString *const NSViewZoomDocumentAttribute;
UIKIT_EXTERN NSString *const NSViewModeDocumentAttribute;
UIKIT_EXTERN NSString *const NSReadOnlyDocumentAttribute;
UIKIT_EXTERN NSString *const NSBackgroundColorDocumentAttribute;
UIKIT_EXTERN NSString *const NSHyphenationFactorDocumentAttribute;
UIKIT_EXTERN NSString *const NSDefaultTabIntervalDocumentAttribute;
UIKIT_EXTERN NSString *const NSTextLayoutSectionsAttribute;


//@interface NSAttributedString (NSAttributedStringDocumentFormats)
//- (id)initWithFileURL:(NSURL *)url options:(NSDictionary *)options documentAttributes:(NSDictionary **)dict error:(NSError **)error;
//- (id)initWithData:(NSData *)data options:(NSDictionary *)options documentAttributes:(NSDictionary **)dict error:(NSError **)error;
//
//- (NSData *)dataFromRange:(NSRange)range documentAttributes:(NSDictionary *)dict error:(NSError **)error;
//- (NSFileWrapper *)fileWrapperFromRange:(NSRange)range documentAttributes:(NSDictionary *)dict error:(NSError **)error;
//
//@end

//@interface NSMutableAttributedString (NSMutableAttributedStringDocumentFormats)
//- (BOOL)readFromFileURL:(NSURL *)url options:(NSDictionary *)opts documentAttributes:(NSDictionary **)dict error:(NSError **)error;
//- (BOOL)readFromData:(NSData *)data options:(NSDictionary *)opts documentAttributes:(NSDictionary **)dict error:(NSError **)error;
//@end

