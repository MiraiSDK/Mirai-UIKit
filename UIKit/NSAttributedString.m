//
//  NSAttributedString.m
//  UIKit
//
//  Created by Chen Yonghui on 4/10/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "NSAttributedString.h"

NSString *const NSFontAttributeName = @"NSFont";
NSString *const NSParagraphStyleAttributeName = @"NSParagraphStyle";
NSString *const NSForegroundColorAttributeName = @"NSColor";
NSString *const NSBackgroundColorAttributeName = @"NSBackgroundColor";
NSString *const NSLigatureAttributeName = @"NSLigature";
NSString *const NSKernAttributeName = @"NSKern";
NSString *const NSStrikethroughStyleAttributeName = @"NSStrikethroughColor";
NSString *const NSUnderlineStyleAttributeName = @"NSUnderline";
NSString *const NSStrokeColorAttributeName = @"NSStrokeColor";
NSString *const NSStrokeWidthAttributeName = @"NSStrokeWidth";
NSString *const NSShadowAttributeName = @"NSShadow";
NSString *const NSTextEffectAttributeName = @"NSTextEffect";

NSString *const NSAttachmentAttributeName = @"NSAttachment";
NSString *const NSLinkAttributeName = @"NSLink";
NSString *const NSBaselineOffsetAttributeName = @"NSBaselineOffset";
NSString *const NSUnderlineColorAttributeName = @"NSUnderlineColor";
NSString *const NSStrikethroughColorAttributeName = @"NSStrikethroughColor";
NSString *const NSObliquenessAttributeName = @"NSObliqueness";
NSString *const NSExpansionAttributeName = @"NSExpansion";

NSString *const NSWritingDirectionAttributeName = @"NSWritingDirection";
NSString *const NSVerticalGlyphFormAttributeName = @"CTVerticalForms";


NSString *const NSTextEffectLetterpressStyle = @"_UIKitNewLetterpressStyle";

@implementation NSMutableAttributedString (NSMutableAttributedStringKitAdditions)

- (void)fixAttributesInRange:(NSRange)range
{
    NS_UNIMPLEMENTED_LOG;
}

@end

NSString *const NSPlainTextDocumentType = @"NSPlainText";
NSString *const NSRTFTextDocumentType = @"NSRTF";
NSString *const NSRTFDTextDocumentType = @"NSRTFD";
NSString *const NSHTMLTextDocumentType = @"NSHTML";

NSString *const NSTextLayoutSectionOrientation = @"NSTextLayoutSectionOrientation";
NSString *const NSTextLayoutSectionRange = @"NSTextLayoutSectionRange";

NSString *const NSDocumentTypeDocumentAttribute = @"DocumentType";

NSString *const NSCharacterEncodingDocumentAttribute = @"CharacterEncoding";
NSString *const NSDefaultAttributesDocumentAttribute = @"DefaultAttributes";

NSString *const NSPaperSizeDocumentAttribute = @"PaperSize";
NSString *const NSPaperMarginDocumentAttribute = @"PaperMargin";

NSString *const NSViewSizeDocumentAttribute = @"ViewSize";
NSString *const NSViewZoomDocumentAttribute = @"ViewZoom";
NSString *const NSViewModeDocumentAttribute = @"ViewMode";
NSString *const NSReadOnlyDocumentAttribute = @"ReadOnly";
NSString *const NSBackgroundColorDocumentAttribute = @"BackgroundColor";
NSString *const NSHyphenationFactorDocumentAttribute = @"HyphenationFactor";
NSString *const NSDefaultTabIntervalDocumentAttribute = @"DefaultTabInterval";
NSString *const NSTextLayoutSectionsAttribute = @"NSTextLayoutSectionsAttribute";
