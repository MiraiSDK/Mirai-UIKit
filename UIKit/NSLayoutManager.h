//
//  NSLayoutManager.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/NSTextStorage.h>
#import <UIKit/UIFont.h>

typedef NS_ENUM(NSInteger, NSTextLayoutOrientation) {
    NSTextLayoutOrientationHorizontal = 0,
    NSTextLayoutOrientationVertical = 1,
};

typedef NS_ENUM(NSInteger, NSGlyphProperty) {
    NSGlyphPropertyNull = (1 << 0),
    NSGlyphPropertyControlCharacter = (1 << 1),
    NSGlyphPropertyElastic = (1 << 2),
    NSGlyphPropertyNonBaseCharacter = (1 << 3)
};

typedef NS_ENUM(NSInteger, NSControlCharacterAction) {
    NSControlCharacterZeroAdvancementAction = (1 << 0),
    NSControlCharacterWhitespaceAction = (1 << 1),
    NSControlCharacterHorizontalTabAction = (1 << 2),
    NSControlCharacterLineBreakAction = (1 << 3),
    NSControlCharacterParagraphBreakAction = (1 << 4),
    NSControlCharacterContainerBreakAction = (1 << 5)
};


@class NSTextContainer;
@class UIColor;

@protocol NSLayoutManagerDelegate;


@interface NSLayoutManager : NSObject <NSCoding>
@property(assign, nonatomic) NSTextStorage *textStorage;


/**************************** Text containers ****************************/
@property(readonly, nonatomic) NSArray *textContainers;

- (void)addTextContainer:(NSTextContainer *)container;
- (void)insertTextContainer:(NSTextContainer *)container atIndex:(NSUInteger)index;
- (void)removeTextContainerAtIndex:(NSUInteger)index;
- (void)textContainerChangedGeometry:(NSTextContainer *)container;


/**************************** Delegate ****************************/

@property(assign, nonatomic) id <NSLayoutManagerDelegate> delegate;


/*********************** Global layout manager options ***********************/

@property(nonatomic) BOOL showsInvisibleCharacters;

@property(nonatomic) BOOL showsControlCharacters;

@property(nonatomic) CGFloat hyphenationFactor;

@property(nonatomic) BOOL usesFontLeading;

@property(nonatomic) BOOL allowsNonContiguousLayout;

@property(readonly, nonatomic) BOOL hasNonContiguousLayout;


/************************** Invalidation **************************/

- (void)invalidateGlyphsForCharacterRange:(NSRange)charRange changeInLength:(NSInteger)delta actualCharacterRange:(NSRangePointer)actualCharRange;

- (void)invalidateLayoutForCharacterRange:(NSRange)charRange actualCharacterRange:(NSRangePointer)actualCharRange;

- (void)invalidateDisplayForCharacterRange:(NSRange)charRange;
- (void)invalidateDisplayForGlyphRange:(NSRange)glyphRange;

- (void)processEditingForTextStorage:(NSTextStorage *)textStorage edited:(NSTextStorageEditActions)editMask range:(NSRange)newCharRange changeInLength:(NSInteger)delta invalidatedRange:(NSRange)invalidatedCharRange;


/************************ Causing glyph generation and layout ************************/

- (void)ensureGlyphsForCharacterRange:(NSRange)charRange;
- (void)ensureGlyphsForGlyphRange:(NSRange)glyphRange;
- (void)ensureLayoutForCharacterRange:(NSRange)charRange;
- (void)ensureLayoutForGlyphRange:(NSRange)glyphRange;
- (void)ensureLayoutForTextContainer:(NSTextContainer *)container;
- (void)ensureLayoutForBoundingRect:(CGRect)bounds inTextContainer:(NSTextContainer *)container;


/************************ Set glyphs and glyph properties ************************/
- (void)setGlyphs:(const CGGlyph *)glyphs properties:(const NSGlyphProperty *)props characterIndexes:(const NSUInteger *)charIndexes font:(UIFont *)aFont forGlyphRange:(NSRange)glyphRange;


/************************ Get glyphs and glyph properties ************************/
@property(readonly, nonatomic) NSUInteger numberOfGlyphs;

- (CGGlyph)glyphAtIndex:(NSUInteger)glyphIndex isValidIndex:(BOOL *)isValidIndex;
- (CGGlyph)glyphAtIndex:(NSUInteger)glyphIndex;
- (BOOL)isValidGlyphIndex:(NSUInteger)glyphIndex;

- (NSGlyphProperty)propertyForGlyphAtIndex:(NSUInteger)glyphIndex;
- (NSUInteger)characterIndexForGlyphAtIndex:(NSUInteger)glyphIndex;
- (NSUInteger)glyphIndexForCharacterAtIndex:(NSUInteger)charIndex;
- (NSUInteger)getGlyphsInRange:(NSRange)glyphRange glyphs:(CGGlyph *)glyphBuffer properties:(NSGlyphProperty *)props characterIndexes:(NSUInteger *)charIndexBuffer bidiLevels:(unsigned char *)bidiLevelBuffer;


/************************ Set layout information ************************/
- (void)setTextContainer:(NSTextContainer *)container forGlyphRange:(NSRange)glyphRange;
- (void)setLineFragmentRect:(CGRect)fragmentRect forGlyphRange:(NSRange)glyphRange usedRect:(CGRect)usedRect;
- (void)setExtraLineFragmentRect:(CGRect)fragmentRect usedRect:(CGRect)usedRect textContainer:(NSTextContainer *)container;
- (void)setLocation:(CGPoint)location forStartOfGlyphRange:(NSRange)glyphRange;
- (void)setNotShownAttribute:(BOOL)flag forGlyphAtIndex:(NSUInteger)glyphIndex;
- (void)setDrawsOutsideLineFragment:(BOOL)flag forGlyphAtIndex:(NSUInteger)glyphIndex;
- (void)setAttachmentSize:(CGSize)attachmentSize forGlyphRange:(NSRange)glyphRange;


/************************ Get layout information ************************/
- (void)getFirstUnlaidCharacterIndex:(NSUInteger *)charIndex glyphIndex:(NSUInteger *)glyphIndex;
- (NSUInteger)firstUnlaidCharacterIndex;
- (NSUInteger)firstUnlaidGlyphIndex;

- (NSTextContainer *)textContainerForGlyphAtIndex:(NSUInteger)glyphIndex effectiveRange:(NSRangePointer)effectiveGlyphRange;
- (CGRect)usedRectForTextContainer:(NSTextContainer *)container;

- (CGRect)lineFragmentRectForGlyphAtIndex:(NSUInteger)glyphIndex effectiveRange:(NSRangePointer)effectiveGlyphRange;

- (CGRect)lineFragmentUsedRectForGlyphAtIndex:(NSUInteger)glyphIndex effectiveRange:(NSRangePointer)effectiveGlyphRange;

@property(readonly, nonatomic) CGRect extraLineFragmentRect;
@property(readonly, nonatomic) CGRect extraLineFragmentUsedRect;
@property(readonly, nonatomic) NSTextContainer *extraLineFragmentTextContainer;

- (CGPoint)locationForGlyphAtIndex:(NSUInteger)glyphIndex;
- (BOOL)notShownAttributeForGlyphAtIndex:(NSUInteger)glyphIndex;
- (BOOL)drawsOutsideLineFragmentForGlyphAtIndex:(NSUInteger)glyphIndex;
- (CGSize)attachmentSizeForGlyphAtIndex:(NSUInteger)glyphIndex;
- (NSRange)truncatedGlyphRangeInLineFragmentForGlyphAtIndex:(NSUInteger)glyphIndex;


/************************ More sophisticated queries ************************/
- (NSRange)glyphRangeForCharacterRange:(NSRange)charRange actualCharacterRange:(NSRangePointer)actualCharRange;
- (NSRange)characterRangeForGlyphRange:(NSRange)glyphRange actualGlyphRange:(NSRangePointer)actualGlyphRange;
- (NSRange)glyphRangeForTextContainer:(NSTextContainer *)container;
- (NSRange)rangeOfNominallySpacedGlyphsContainingIndex:(NSUInteger)glyphIndex;
- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange inTextContainer:(NSTextContainer *)container;
- (NSRange)glyphRangeForBoundingRect:(CGRect)bounds inTextContainer:(NSTextContainer *)container;
- (NSRange)glyphRangeForBoundingRectWithoutAdditionalLayout:(CGRect)bounds inTextContainer:(NSTextContainer *)container;
- (NSUInteger)glyphIndexForPoint:(CGPoint)point inTextContainer:(NSTextContainer *)container fractionOfDistanceThroughGlyph:(CGFloat *)partialFraction;
- (NSUInteger)glyphIndexForPoint:(CGPoint)point inTextContainer:(NSTextContainer *)container;
- (CGFloat)fractionOfDistanceThroughGlyphForPoint:(CGPoint)point inTextContainer:(NSTextContainer *)container;
- (NSUInteger)characterIndexForPoint:(CGPoint)point inTextContainer:(NSTextContainer *)container fractionOfDistanceBetweenInsertionPoints:(CGFloat *)partialFraction;
- (NSUInteger)getLineFragmentInsertionPointsForCharacterAtIndex:(NSUInteger)charIndex alternatePositions:(BOOL)aFlag inDisplayOrder:(BOOL)dFlag positions:(CGFloat *)positions characterIndexes:(NSUInteger *)charIndexes;
- (void)enumerateLineFragmentsForGlyphRange:(NSRange)glyphRange usingBlock:(void (^)(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop))block;

- (void)enumerateEnclosingRectsForGlyphRange:(NSRange)glyphRange withinSelectedGlyphRange:(NSRange)selectedRange inTextContainer:(NSTextContainer *)textContainer usingBlock:(void (^)(CGRect rect, BOOL *stop))block;


/************************ Drawing support ************************/

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin;
- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin;

- (void)showCGGlyphs:(const CGGlyph *)glyphs positions:(const CGPoint *)positions count:(NSUInteger)glyphCount font:(UIFont *)font matrix:(CGAffineTransform)textMatrix attributes:(NSDictionary *)attributes inContext:(CGContextRef)graphicsContext;

- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color;

- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal baselineOffset:(CGFloat)baselineOffset lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin;
- (void)underlineGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin;

- (void)drawStrikethroughForGlyphRange:(NSRange)glyphRange strikethroughType:(NSUnderlineStyle)strikethroughVal baselineOffset:(CGFloat)baselineOffset lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin;
- (void)strikethroughGlyphRange:(NSRange)glyphRange strikethroughType:(NSUnderlineStyle)strikethroughVal lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin;

@end


@protocol NSLayoutManagerDelegate <NSObject>
@optional

/************************ Glyph generation ************************/
- (NSUInteger)layoutManager:(NSLayoutManager *)layoutManager shouldGenerateGlyphs:(const CGGlyph *)glyphs properties:(const NSGlyphProperty *)props characterIndexes:(const NSUInteger *)charIndexes font:(UIFont *)aFont forGlyphRange:(NSRange)glyphRange;


/************************ Line layout ************************/
/* These methods are invoked while each line is laid out.  They allow NSLayoutManager delegate to customize the shape of line.
 */
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect;
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingBeforeGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect;
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect;
- (NSControlCharacterAction)layoutManager:(NSLayoutManager *)layoutManager shouldUseAction:(NSControlCharacterAction)action forControlCharacterAtIndex:(NSUInteger)charIndex;
- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex;
- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByHyphenatingBeforeCharacterAtIndex:(NSUInteger)charIndex;
- (CGRect)layoutManager:(NSLayoutManager *)layoutManager boundingBoxForControlGlyphAtIndex:(NSUInteger)glyphIndex forTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)proposedRect glyphPosition:(CGPoint)glyphPosition characterIndex:(NSUInteger)charIndex;


/************************ Layout processing ************************/
- (void)layoutManagerDidInvalidateLayout:(NSLayoutManager *)sender;
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag;
- (void)layoutManager:(NSLayoutManager *)layoutManager textContainer:(NSTextContainer *)textContainer didChangeGeometryFromSize:(CGSize)oldSize;

@end

@protocol NSTextLayoutOrientationProvider
@property(nonatomic) NSTextLayoutOrientation layoutOrientation;

@end
