package org.tiny4.CocoaActivity;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.view.View;
import android.text.TextWatcher;
import android.view.View.OnFocusChangeListener;
import android.widget.EditText;

import android.util.Log;

import java.lang.CharSequence;
import java.lang.Override;
import java.lang.String;

public class GLTextViewRender extends GLViewRender {
    private GLTextView _view;
    
    public GLTextViewRender(Context context, int glTexID, int width, int height) {
        super(context,glTexID,width,height);
    }
    
    @Override
    protected View onCreateTargetView(Activity activity) {
        GLTextView v = new GLTextView(activity);
        v.setRender(this);
        _view = v;
        return v;
    }
    
    public final void setText(java.lang.CharSequence text) {
        final CharSequence aText = text;
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                _view.setText(aText);
                synchronized (this) {
                    this.notify() ;
                }
            }
        };
        
        runOnUiThreadAndWait(aRunnable);
    }
    
    // componts range are [0..255]
    public void setTextColor(int alpha, int red, int green, int blue) {
        final int color =  Color.argb(alpha,red,green,blue);
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                _view.setTextColor(color);
                synchronized (this) {
                    this.notify() ;
                }
            }
        };
        
        runOnUiThreadAndWait(aRunnable);
    }
    
    public void setTextAlignment(final int textAlignment) {
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                _view.setTextAlignment(textAlignment);
                synchronized (this) {
                    this.notify() ;
                }
            }
        };
        
        runOnUiThreadAndWait(aRunnable);
    }
    
    public void setGravity(final int gravity) {
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                _view.setGravity(gravity);
                synchronized (this) {
                    this.notify() ;
                }
            }
        };
        
        runOnUiThreadAndWait(aRunnable);
    }
    
    public void setHint(final java.lang.CharSequence hint) {
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                _view.setHint(hint);
                synchronized (this) {
                    this.notify() ;
                }
            }
        };
        
        runOnUiThreadAndWait(aRunnable);
    }
    
    public void setFont(final String fontName, final int fontSize) {
        final Typeface tf = Typeface.create(fontName, 0);
        
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                //_view.setTypeface(tf);
                _view.setTextSize(fontSize);
                synchronized (this) {
                    this.notify() ;
                }
            }
        };
        
        runOnUiThreadAndWait(aRunnable);
    }
    
    public void addTextChangedListener (final TextWatcher watcher) {
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                _view.addTextChangedListener(watcher);
            }
        };
        runOnUiThreadAsync(aRunnable);
    }
    
    public void setOnFocusChangeListener (final OnFocusChangeListener focusChange) {
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                _view.setOnFocusChangeListener(focusChange);
            }
        };
        runOnUiThreadAsync(aRunnable);
    }
    
    private String mText = null;
    public String getTextString() {
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                mText = _view.getText().toString();
                synchronized (this) {
                    this.notify() ;
                }
            }
        };
        
        runOnUiThreadAndWait(aRunnable);
        return  mText;
    }
    @Override
    public void onDestory() {
        super.onDestory();
    }
}