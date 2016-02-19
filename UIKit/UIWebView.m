/*
 */

#import "UIWebView.h"
#import "UIAndroidWebView.h"
#import "TNJavaBridgeDefinition.h"
#import "TNJavaBridgeProxy.h"
#import "TNJavaBridgeCallbackContext.h"

@implementation UIWebView
{
    UIAndroidWebView *_backend;
    TNJavaBridgeProxy *_listenerBridgeProxy;
}
@synthesize request=_request, delegate=_delegate, dataDetectorTypes=_dataDetectorTypes, scalesPageToFit=_scalesPageToFit;

static TNJavaBridgeDefinition *_webViewListenerDefinition;

+ (void)initialize
{
    NSString *webViewListenerClass = @"org.tiny4.CocoaActivity.GLWebViewListener";
    NSArray *webViewListenerSignatures = @[
                                    @"onShouldOverrideUrlLoading(android.webkit.WebView,java.lang.String)",
                                    @"onPageStarted(android.webkit.WebView,java.lang.String)",
                                    @"onPageFinished(android.webkit.WebView,java.lang.String)",];
    _webViewListenerDefinition = [[TNJavaBridgeDefinition alloc] initWithProxiedClassName:webViewListenerClass withMethodSignatures:webViewListenerSignatures];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _scalesPageToFit = NO;
        
//        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
//        [self addSubview:_scrollView];
        
        _backend = [[UIAndroidWebView alloc] initWithFrame:self.bounds];
        [self addSubview:_backend];
        [self _generateListenerBridgeProxy];
        
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
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
    [_backend loadHTMLString:string baseURL:baseURL];
}

- (void)loadRequest:(NSURLRequest *)request
{
    if (request != _request) {
        _request = request;
        
        [_backend loadRequest:request];
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

#pragma mark - handle lisenter events

- (void)_generateListenerBridgeProxy
{
    _listenerBridgeProxy = [[TNJavaBridgeProxy alloc] initWithDefinition:_webViewListenerDefinition];
    [_listenerBridgeProxy methodIndex:0 target:self action:@selector(_handleshouldOverrideUrlLoading:)];
    [_listenerBridgeProxy methodIndex:1 target:self action:@selector(_handlePageStarted:)];
    [_listenerBridgeProxy methodIndex:2 target:self action:@selector(_handlePageFinished:)];
    [_backend setListenerBridgeProxy:_listenerBridgeProxy];
}

- (void)_handleshouldOverrideUrlLoading:(TNJavaBridgeCallbackContext *)context
{
    BOOL shouldOverrideUrlLoading = NO;
    if ([_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        shouldOverrideUrlLoading = ![_delegate webView:self shouldStartLoadWithRequest:nil navigationType:0];
    }
    [_backend setShouldOverrideUrlLoadingValue:shouldOverrideUrlLoading];
}

- (void)_handlePageStarted:(TNJavaBridgeCallbackContext *)context
{
    [_delegate webViewDidStartLoad:self];
}

- (void)_handlePageFinished:(TNJavaBridgeCallbackContext *)context
{
    [_delegate webViewDidFinishLoad:self];
}

#pragma mark -
- (id)initWithCoder:(NSCoder *)aDecoder
{
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_backend touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_backend touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_backend touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_backend touchesCancelled:touches withEvent:event];
}

@end
