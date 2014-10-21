//
//  UITextInput.h
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

#import <UIKit/UITextInputTraits.h>
#import <UIKit/UIResponder.h>

@class UIView;

@protocol UIKeyInput <UITextInputTraits>

- (BOOL)hasText;
- (void)insertText:(NSString *)text;
- (void)deleteBackward;

@end

@class NSTextAlternatives;
@class UITextPosition;
@class UITextRange;
@class UITextSelectionRect;

@protocol UITextInputTokenizer;
@protocol UITextInputDelegate;

typedef NS_ENUM(NSInteger, UITextStorageDirection) {
    UITextStorageDirectionForward = 0,
    UITextStorageDirectionBackward
};

typedef NS_ENUM(NSInteger, UITextLayoutDirection) {
    UITextLayoutDirectionRight = 2,
    UITextLayoutDirectionLeft,
    UITextLayoutDirectionUp,
    UITextLayoutDirectionDown
};

typedef NSInteger UITextDirection;

typedef NS_ENUM(NSInteger, UITextWritingDirection) {
    UITextWritingDirectionNatural = -1,
    UITextWritingDirectionLeftToRight = 0,
    UITextWritingDirectionRightToLeft,
};

typedef NS_ENUM(NSInteger, UITextGranularity) {
    UITextGranularityCharacter,
    UITextGranularityWord,
    UITextGranularitySentence,
    UITextGranularityParagraph,
    UITextGranularityLine,
    UITextGranularityDocument
};

@interface UIDictationPhrase : NSObject
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSArray *alternativeInterpretations;
@end

@protocol UITextInput <UIKeyInput>
@required
- (NSString *)textInRange:(UITextRange *)range;
- (void)replaceRange:(UITextRange *)range withText:(NSString *)text;
@property (readwrite, copy) UITextRange *selectedTextRange;
@property (nonatomic, readonly) UITextRange *markedTextRange;
@property (nonatomic, copy) NSDictionary *markedTextStyle;
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange;
- (void)unmarkText;


@property (nonatomic, readonly) UITextPosition *beginningOfDocument;
@property (nonatomic, readonly) UITextPosition *endOfDocument;


- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition;
- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset;
- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset;

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other;
- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition;

@property (nonatomic, assign) id <UITextInputDelegate> inputDelegate;

@property (nonatomic, readonly) id <UITextInputTokenizer> tokenizer;

- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction;
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction;

- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction;
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range;

- (CGRect)firstRectForRange:(UITextRange *)range;
- (CGRect)caretRectForPosition:(UITextPosition *)position;
- (NSArray *)selectionRectsForRange:(UITextRange *)range;

- (UITextPosition *)closestPositionToPoint:(CGPoint)point;
- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range;
- (UITextRange *)characterRangeAtPoint:(CGPoint)point;

@optional

- (BOOL)shouldChangeTextInRange:(UITextRange *)range replacementText:(NSString *)text;

- (NSDictionary *)textStylingAtPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction;

- (UITextPosition *)positionWithinRange:(UITextRange *)range atCharacterOffset:(NSInteger)offset;
- (NSInteger)characterOffsetOfPosition:(UITextPosition *)position withinRange:(UITextRange *)range;

@property (nonatomic, readonly) UIView *textInputView;

@property (nonatomic) UITextStorageDirection selectionAffinity;


- (void)insertDictationResult:(NSArray *)dictationResult;

- (void)dictationRecordingDidEnd;
- (void)dictationRecognitionFailed;

- (id)insertDictationResultPlaceholder;
- (CGRect)frameForDictationResultPlaceholder:(id)placeholder;
- (void)removeDictationResultPlaceholder:(id)placeholder willInsertResult:(BOOL)willInsertResult;

@end

//UIKIT_EXTERN
NSString *const UITextInputTextBackgroundColorKey; // NS_DEPRECATED_IOS(3_2, 8_0, "Use NSBackgroundColorAttributeName instead"); // Key to a UIColor
//UIKIT_EXTERN
NSString *const UITextInputTextColorKey;           //NS_DEPRECATED_IOS(3_2, 8_0, "Use NSForegroundColorAttributeName instead"); // Key to a UIColor
//UIKIT_EXTERN
NSString *const UITextInputTextFontKey;            //NS_DEPRECATED_IOS(3_2, 8_0, "Use NSFontAttributeName instead");

@interface UITextPosition : NSObject

@end

@interface UITextRange : NSObject

@property (nonatomic, readonly, getter=isEmpty) BOOL empty;     //  Whether the range is zero-length.
@property (nonatomic, readonly) UITextPosition *start;
@property (nonatomic, readonly) UITextPosition *end;

@end

@interface UITextSelectionRect : NSObject

@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) UITextWritingDirection writingDirection;
@property (nonatomic, readonly) BOOL containsStart; // Returns YES if the rect contains the start of the selection.
@property (nonatomic, readonly) BOOL containsEnd; // Returns YES if the rect contains the end of the selection.
@property (nonatomic, readonly) BOOL isVertical; // Returns YES if the rect is for vertically oriented text.

@end

@protocol UITextInputDelegate <NSObject>

- (void)selectionWillChange:(id <UITextInput>)textInput;
- (void)selectionDidChange:(id <UITextInput>)textInput;
- (void)textWillChange:(id <UITextInput>)textInput;
- (void)textDidChange:(id <UITextInput>)textInput;

@end

@protocol UITextInputTokenizer <NSObject>

@required

- (UITextRange *)rangeEnclosingPosition:(UITextPosition *)position withGranularity:(UITextGranularity)granularity inDirection:(UITextDirection)direction;
- (BOOL)isPosition:(UITextPosition *)position atBoundary:(UITextGranularity)granularity inDirection:(UITextDirection)direction;
- (UITextPosition *)positionFromPosition:(UITextPosition *)position toBoundary:(UITextGranularity)granularity inDirection:(UITextDirection)direction;
- (BOOL)isPosition:(UITextPosition *)position withinTextUnit:(UITextGranularity)granularity inDirection:(UITextDirection)direction;

@end


/* A recommended base implementation of the tokenizer protocol. Subclasses are responsible
 * for handling directions and granularities affected by layout.*/
@interface UITextInputStringTokenizer : NSObject <UITextInputTokenizer>

- (instancetype)initWithTextInput:(UIResponder <UITextInput> *)textInput;

@end

/* The UITextInputMode class should not be subclassed. It is to allow other in-app functionality to adapt
 * based on the keyboard language. Different UITextInputMode objects may have the same primaryLanguage. */
@interface UITextInputMode : NSObject <NSSecureCoding>

@property (nonatomic, readonly, retain) NSString *primaryLanguage; // The primary language, if any, of the input mode.  A BCP 47 language identifier such as en-US

// To query the UITextInputMode, refer to the UIResponder method -textInputMode.
+ (UITextInputMode *)currentInputMode; // NS_DEPRECATED_IOS(4_2, 7_0); // The current input mode.  Nil if unset.
+ (NSArray *)activeInputModes; // The activate input modes.

@end

//UIKIT_EXTERN
NSString *const UITextInputCurrentInputModeDidChangeNotification;
