/*
 */

#import "UIWebView.h"

@implementation UIWebView
@synthesize request=_request, delegate=_delegate, dataDetectorTypes=_dataDetectorTypes, scalesPageToFit=_scalesPageToFit;

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _scalesPageToFit = NO;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:_scrollView];
        
    }
    return self;
}

- (void)dealloc
{
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setDelegate:(id<UIWebViewDelegate>)newDelegate
{
    _delegate = newDelegate;
//    _delegateHas.shouldStartLoadWithRequest = [_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)];
//    _delegateHas.didFailLoadWithError = [_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)];
//    _delegateHas.didFinishLoad = [_delegate respondsToSelector:@selector(webViewDidFinishLoad:)];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
}

- (void)loadRequest:(NSURLRequest *)request
{
    if (request != _request) {
        _request = request;
    }
}

- (void)stopLoading
{
}

- (void)reload
{
}

- (void)goBack
{
}

- (void)goForward
{
}

- (BOOL)isLoading
{
    return NO;
}

- (BOOL)canGoBack
{
    return NO;
}

- (BOOL)canGoForward
{
    return NO;
}

- (BOOL)scalesPageToFit
{
    return false;
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    return nil;
}

#pragma mark -
- (id)initWithCoder:(NSCoder *)aDecoder
{
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

@end
