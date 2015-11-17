package org.tiny4.CocoaActivity;

import android.app.Activity;
import android.content.Context;
import android.view.View;

public class GLSingleLineTextViewRender extends GLTextViewRender {

    public GLSingleLineTextViewRender(Context context, int glTexID, int width, int height) {
        super(context, glTexID, width, height);
    }
    
    @Override
    protected View onCreateTargetView(Activity activity) {
        GLTextView v = (GLTextView) super.onCreateTargetView(activity);
        v.setSingleLine();
        return v;
    }
}