package org.tiny4.CocoaActivity;

import android.content.Context;
import android.graphics.Canvas;

import android.view.Surface;

import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import android.graphics.Bitmap;
import android.webkit.WebSettings;

import android.util.Log;
/**
 * Created by Yonghui Chen on 10/23/14.
 */
public class GLWebView extends WebView {
    private GLViewRender mRender;
    private GLWebViewListener webViewListener;
    
    private final Object bridgeLock = new Object();
    private Boolean shouldOverrideUrlLoadingValue = null;
    
    public  GLWebView(Context context) {
        super(context);

        setWebChromeClient(new WebChromeClient(){});
        setWebViewClient(new WebViewClient() {
        
            @Override public void onPageFinished(WebView view, String url) {
                if (webViewListener != null) {
                    webViewListener.onPageFinished(view, url);
                }
            }
            
            @Override public void onPageStarted(WebView view, String url, Bitmap favicon) {
                if (webViewListener != null) {
                    webViewListener.onPageStarted(view, url);
                }
            }
            
            @Override public boolean shouldOverrideUrlLoading (WebView view, String url) {
                boolean resultValue = true;
                if (webViewListener != null) {
                    webViewListener.onShouldOverrideUrlLoading(view, url);
                    resultValue = getShouldOverrideUrlLoadingValue();
                }
                return resultValue;
            }
            
            @Override public void onReceivedError (WebView view, int errorCode, String description, String failingUrl) {
                if (webViewListener != null) {
                    webViewListener.onReceivedError(view, errorCode, description, failingUrl);
                }
            }
        
        });

        setHorizontalScrollBarEnabled(false);
        setVerticalScrollBarEnabled(false);
        
        WebSettings s = getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setLoadWithOverviewMode(true);
        s.setUseWideViewPort(true);
    }

    public void setRender(GLViewRender r) {
        mRender = r;
    }
    
    public void setWebViewListener(GLWebViewListener webViewListener) {
        this.webViewListener = webViewListener;
    }
    
    private boolean getShouldOverrideUrlLoadingValue() {
        if (shouldOverrideUrlLoadingValue == null) {
            return false;
        }
        boolean resultValue = shouldOverrideUrlLoadingValue;
        shouldOverrideUrlLoadingValue = null;
        return resultValue;
    }
    
    public void setShouldOverrideUrlLoadingValue(boolean value) {
        shouldOverrideUrlLoadingValue = value;
    }
    
    @Override protected  void onDraw (Canvas canvas) {
        Surface mSurface = mRender.getSurface();

        if (mSurface != null) {

            try {
                final Canvas surfaceCanvas = mSurface.lockCanvas(null);
                surfaceCanvas.translate(-getScrollX(),-getScrollY());
                super.onDraw(surfaceCanvas);
                mSurface.unlockCanvasAndPost(surfaceCanvas);
            } catch (Surface.OutOfResourcesException excp) {
                excp.printStackTrace();
            }

        }

        //super.onDraw(canvas);
    }

    @Override
    public void invalidate() {
        super.invalidate();

        mRender.setTargetViewDirty();
    }
}
