/*
 */

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIGestureRecognizer.h>

// Begins:  when two touches have moved enough to be considered a pinch
// Changes: when a finger moves while two fingers remain down
// Ends:    when both fingers have lifted

@interface UIPinchGestureRecognizer : UIGestureRecognizer {
    @package
    CGFloat           _initialTouchDistance;
    CGFloat           _initialTouchScale;
    NSTimeInterval    _lastTouchTime;
    CGFloat           _velocity;
    CGFloat           _previousVelocity;
    CGFloat           _scaleThreshold;
    CGAffineTransform _transform;
    CGPoint           _anchorPoint;
//    UITouch          *_touches[2];
    CGFloat           _hysteresis;
    id                _transformAnalyzer;
    unsigned int      _endsOnSingleTouch:1;
}

@property (nonatomic) CGFloat scale;
@property (nonatomic, readonly) CGFloat velocity;

@end
