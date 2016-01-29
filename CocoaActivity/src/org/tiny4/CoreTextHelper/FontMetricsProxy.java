package org.tiny4.CoreTextHelper;

import android.graphics.Typeface;
import android.graphics.Paint;

import android.util.Log;

public class FontMetricsProxy extends Object {
    
    Paint.FontMetrics fontMetrics;
    
    public FontMetricsProxy(String fontFamily, float fontSize, boolean bold, boolean italic) {
        Typeface typeface = Typeface.create(fontFamily, styleWith(bold, italic));
        Paint paint = new Paint();
        
        paint.setTextSize(fontSize);
        paint.setTypeface(typeface);
        
        fontMetrics = paint.getFontMetrics();
    }
    
    private int styleWith(boolean bold, boolean italic) {
        if (!bold && !italic) {
            return Typeface.NORMAL;
        } else if (bold && !italic) {
            return Typeface.ITALIC;
        } else if (!bold && italic) {
            return Typeface.BOLD;
        } else {
            return Typeface.BOLD_ITALIC;
        }
    }
    
    public float ascent() {
        return fontMetrics.ascent;
    }
    
    public float bottom() {
        return fontMetrics.bottom;
    }
    
    public float descent() {
        return fontMetrics.descent;
    }
    
    public float leading() {
        return fontMetrics.leading;
    }
    
    public float top() {
        return fontMetrics.top;
    }
}