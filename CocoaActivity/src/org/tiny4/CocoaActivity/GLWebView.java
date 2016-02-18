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
    
    public  GLWebView(Context context) {
        super(context);

        setWebChromeClient(new WebChromeClient(){});
        setWebViewClient(new WebViewClient() {
        
            @Override public void onPageFinished(WebView view, String url) {
                if (webViewListener != null) {
                    webViewListener.onPageFinished(view, url);
                    Log.i("NSLog", "[WebView Test] call on page finished");
                }
            }
            
            @Override public void onPageStarted(WebView view, String url, Bitmap favicon) {
                if (webViewListener != null) {
                    webViewListener.onPageStarted(view, url);
                    Log.i("NSLog", "[WebView Test] call on page started");
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
