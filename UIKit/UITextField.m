//
//  UITextField.m
//  UIKit
//
//  Created by Chen Yonghui on 10/20/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import "UITextField+UIPrivate.h"

#import "UIAndroidTextView.h"
@interface UITextField ()
@property (nonatomic, strong) UIAndroidTextView *backend;
@end

@implementation UITextField
//UITextInputTraits
@synthesize autocapitalizationType = _autocapitalizationType;
@synthesize autocorrectionType = _autocorrectionType;
@synthesize enablesReturnKeyAutomatically = _enablesReturnKeyAutomatically;
@synthesize keyboardAppearance = _keyboardAppearance;
@synthesize keyboardType = _keyboardType;
@synthesize returnKeyType = _returnKeyType;
@synthesize secureTextEntry = _secureTextEntry;

// UITextInput
@synthesize selectedTextRange = _selectedTextRange;
@synthesize markedTextRange = _markedTextRange;
@synthesize markedTextStyle = _markedTextStyle;
@synthesize beginningOfDocument = _beginningOfDocument;
@synthesize endOfDocument = _endOfDocument;
@synthesize inputDelegate = _inputDelegate;
@synthesize tokenizer = _tokenizer;

#pragma mark - 
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIAndroidTextView *atv = [[UIAndroidTextView alloc] initWithFrame:self.bounds];
        [atv setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:atv];
        _backend = atv;
        [self addSubview:atv];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    [_backend setText:text];
}

- (NSString *)text
{
    return [_backend text];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _backend.placeholder = placeholder;
}

- (NSString *)placeholder
{
    return _backend.placeholder;
}

- (void)setTextWatcherListener:(TNJavaBridgeProxy *)textWatcherListener
{
    [_backend setTextWatcherListener:textWatcherListener];
}

- (void)setOnFocusChangeListener:(TNJavaBridgeProxy *)focusChangeLisenter
{
    [_backend setOnFocusChangeListener:focusChangeLisenter];
}

- (CGRect)borderRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    return CGRectZero;
}

- (void)drawTextInRect:(CGRect)rect
{
    
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    
}

#pragma mark - UITextInputTraits

#pragma mark - UIKeyInput
- (BOOL)hasText
{
    return NO;
}

- (void)insertText:(NSString *)text
{
    
}

- (void)deleteBackward
{
    
}
#pragma mark - UITextInput protocol
- (NSString *)textInRange:(UITextRange *)range
{
    return nil;
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
    
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    
}
- (void)unmarkText
{
    
}

- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    return nil;
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset
{
    return nil;
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    return nil;
}

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
    return NSOrderedSame;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition
{
    return 0;
}

- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction
{
    return nil;
}

- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction
{
    return nil;
}

- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
    return UITextWritingDirectionLeftToRight;
}

- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range
{
    
}

- (CGRect)firstRectForRange:(UITextRange *)range
{
    return CGRectZero;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    return CGRectZero;
}

- (NSArray *)selectionRectsForRange:(UITextRange *)range
{
    return nil;
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    return nil;
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range
{
    return nil;
}

- (UITextRange *)characterRangeAtPoint:(CGPoint)point
{
    return nil;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
    [_backend touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [_backend touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [_backend touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_backend touchesCancelled:touches withEvent:event];
}
@end

NSString *const UITextFieldTextDidBeginEditingNotification = @"UITextFieldTextDidBeginEditingNotification";
NSString *const UITextFieldTextDidEndEditingNotification = @"UITextFieldTextDidEndEditingNotification";
NSString *const UITextFieldTextDidChangeNotification = @"UITextFieldTextDidChangeNotification";
