package org.tiny4.CocoaActivity;

import android.webkit.WebView;

public interface GLWebViewListener {
    
    void onShouldOverrideUrlLoading(WebView view, String url);
    void onPageStarted(WebView view, String url);
    void onPageFinished(WebView view, String url);

}