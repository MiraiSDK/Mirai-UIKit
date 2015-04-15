package org.tiny4.CocoaActivity;


import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.text.method.ScrollingMovementMethod;
import android.view.Gravity;
import android.widget.EditText;
import android.widget.TextView;
import android.graphics.Canvas;
import android.view.Surface;

import java.lang.String;


public class GLTextView extends EditText {

    private GLViewRender mRender;

    public GLTextView(Context context) {
        super(context);

        this.setTextColor(Color.BLACK);
        //this.setVerticalScrollBarEnabled(true);
        //this.setMovementMethod(new ScrollingMovementMethod());
//        this.setCursorVisible(false);
//this.setOverScrollMode(OVER_SCROLL_ALWAYS);
        this.setBackgroundColor(Color.TRANSPARENT);
    }

    public void setRender(GLViewRender r) {
        mRender = r;
    }

    @Override protected  void onDraw (Canvas canvas) {
        Surface mSurface = mRender.getSurface();

        if (mSurface != null) {

            try {
                final Canvas surfaceCanvas = mSurface.lockCanvas(null);

                surfaceCanvas.translate(-getScrollX(),-getScrollY());
                surfaceCanvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);
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

        if (mRender != null)
            mRender.setTargetViewDirty();
    }
}