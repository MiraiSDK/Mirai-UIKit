/*
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIDataDetectors.h>
#import <UIKit/UIScrollView.h>


typedef NS_ENUM(NSInteger, UIWebViewNavigationType) {
    UIWebViewNavigationTypeLinkClicked,
    UIWebViewNavigationTypeFormSubmitted,
    UIWebViewNavigationTypeBackForward,
    UIWebViewNavigationTypeReload,
    UIWebViewNavigationTypeFormResubmitted,
    UIWebViewNavigationTypeOther
};

typedef NS_ENUM(NSInteger, UIWebPaginationMode) {
    UIWebPaginationModeUnpaginated,
    UIWebPaginationModeLeftToRight,
    UIWebPaginationModeTopToBottom,
    UIWebPaginationModeBottomToTop,
    UIWebPaginationModeRightToLeft
};

typedef NS_ENUM(NSInteger, UIWebPaginationBreakingMode) {
    UIWebPaginationBreakingModePage,
    UIWebPaginationBreakingModeColumn
};

@class UIWebViewInternal;
@protocol UIWebViewDelegate;

@interface UIWebView : UIView  <NSCoding, UIScrollViewDelegate> {
@private
    __unsafe_unretained id _delegate;
    NSURLRequest *_request;
    UIDataDetectorTypes _dataDetectorTypes;
    //WebView *_webView;
    //UIViewAdapter *_webViewAdapter;
    BOOL _scalesPageToFit;
    
    struct {
        unsigned shouldStartLoadWithRequest : 1;
        unsigned didFailLoadWithError : 1;
        unsigned didFinishLoad : 1;
    } _delegateHas;
}

@property(nonatomic,assign) id<UIWebViewDelegate> delegate;

@property(nonatomic,readonly,retain) UIScrollView *scrollView;


- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

@property(nonatomic,readonly,retain) NSURLRequest *request;

- (void)reload;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;

@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@property (nonatomic, assign) BOOL scalesPageToFit;

@property(nonatomic) BOOL detectsPhoneNumbers; // NS_DEPRECATED_IOS(2_0, 3_0);
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;

@property (nonatomic) BOOL allowsInlineMediaPlayback; // iPhone Safari defaults to NO. iPad Safari defaults to YES
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction; //default to YES
@property (nonatomic) BOOL mediaPlaybackAllowsAirPlay; // iPhone and iPad Safari both default to YES

@property (nonatomic) BOOL suppressesIncrementalRendering; // iPhone and iPad Safari both default to NO

@property (nonatomic) BOOL keyboardDisplayRequiresUserAction; // default is YES

@property (nonatomic) UIWebPaginationMode paginationMode; //NS_AVAILABLE_IOS(7_0);
@property (nonatomic) UIWebPaginationBreakingMode paginationBreakingMode; //NS_AVAILABLE_IOS(7_0);
@property (nonatomic) CGFloat pageLength; //NS_AVAILABLE_IOS(7_0);
@property (nonatomic) CGFloat gapBetweenPages; //NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readonly) NSUInteger pageCount; //NS_AVAILABLE_IOS(7_0);

@end

@protocol UIWebViewDelegate <NSObject>

@optional
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error;

@end


