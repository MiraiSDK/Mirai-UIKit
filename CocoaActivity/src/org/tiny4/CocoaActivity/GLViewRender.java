package org.tiny4.CocoaActivity;

import android.app.Activity;
import android.content.Context;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.graphics.drawable.ColorDrawable;
import android.os.Looper;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.PopupWindow;

import android.util.Log;

/**
 * Created by Yonghui Chen on 10/31/14.
 */

public class GLViewRender extends Object implements SurfaceTexture.OnFrameAvailableListener {
    private static final String TAG = "GLViewRender";
    private static Activity mActivity;
    private View mTarget;
    private static PopupWindow _popUp;
    private static LinearLayout _windowContentLayout;
    private ViewGroup.LayoutParams _layoutParams;
    private static Window _rootWindow;

    private int mWidth;
    private int mHeight;
    private final int _glTexId;

    private Surface mSurface = null;
    private SurfaceTexture surfaceTexture = null;

    private boolean isTargetDirty = true;
    private boolean needsUpdateSurface = false;
    private native void nativeOnKeyboardShowHide(int shown, int height);
    

    public GLViewRender(Context context, int glTexID, int width, int height) {
        super();

        _glTexId = glTexID;
        Log.v(TAG,"glTextureID:"+glTexID);
        if (mActivity == null) {
            mActivity = (Activity)context;

            _rootWindow = mActivity.getWindow();

            View rootView = _rootWindow.getDecorView().findViewById(android.R.id.content);

            rootView.getViewTreeObserver().addOnGlobalLayoutListener(
                    new ViewTreeObserver.OnGlobalLayoutListener() {
                        public void onGlobalLayout(){
                            Rect r = new Rect();

                            View view = _rootWindow.getDecorView();
                            view.getWindowVisibleDisplayFrame(r);
                            Display display = view.getDisplay();
                            Rect displayRect = new Rect();
                            display.getRectSize(displayRect);
                            // r.left, r.top, r.right, r.bottom
                            Log.v(TAG,"displayRect:"+displayRect+" decorViewRect:"+r);

                            int height = r.height();
                            if (displayRect.height() == r.height()) {
                                //keyboard hidden
                                Log.v(TAG,"Keyboard is hidden");
                                nativeOnKeyboardShowHide(0,height);

                            } else {
                                // keyboard show
                                Log.v(TAG,"Keyboard is shown");
                                nativeOnKeyboardShowHide(1,height);
                            }


                        }
                    });
        }
        if (mActivity != context) {
            Log.e(TAG,"activity not equale!");
        }


        setSize(width,height);

        createTargetViewOnUiThread();
    }

    public Surface getSurface() {
        return mSurface;
    }

    protected View onCreateTargetView(Activity activity) {
        return new View(activity);
    }

    public View getTargetView() {
        return mTarget;
    }

    public void onDestory() {
        Log.i(TAG, "onDestory");
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {

                _windowContentLayout.removeView(mTarget);
                mTarget = null;
                
                //FIXME: dismiss popUp while there is 0 target view
                //_popUp.dismiss();
                synchronized (this) {
                    this.notify() ;
                }
            }
        };

        runOnUiThreadAndWait(aRunnable);
    }

    private void recreateSurface()
    {
        Log.v(TAG,"recreate surface, textid:"+_glTexId);
        mSurface = null;
        surfaceTexture = null;

        if (_glTexId > 0) {
            Log.v(TAG,"glTextureID:"+ _glTexId+" width:"+mWidth+" height:"+mHeight);
            surfaceTexture = new SurfaceTexture(_glTexId);
            surfaceTexture.setDefaultBufferSize(mWidth,mHeight);
            surfaceTexture.setOnFrameAvailableListener(this);
            mSurface = new Surface(surfaceTexture);
        }
    }

    synchronized public void onFrameAvailable(SurfaceTexture surface) {
        needsUpdateSurface = true;
    }

    public void setSize(final int width, final int height) {

        mWidth = width;
        mHeight = height;

        recreateSurface();

        if (_layoutParams != null) {
            Runnable aRunnable = new Runnable() {
                @Override
                public void run() {
                    ViewGroup.LayoutParams params = mTarget.getLayoutParams();
                    params.width = width;
                    params.height = height;
                    mTarget.setLayoutParams(params);

                    synchronized (this) {
                        this.notify() ;
                    }
                }
            };

            runOnUiThreadAndWait(aRunnable);
        }
    }
            
    protected void runOnUiThreadAndWait(Runnable aRunnable) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            throw new IllegalStateException("This method should only be called off the Android UI thread");
        }

        synchronized (aRunnable) {
            mActivity.runOnUiThread(aRunnable);

            try {
                aRunnable.wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    protected void runOnUiThreadAsync(Runnable aRunnable) {
        mActivity.runOnUiThread(aRunnable);
    }
    
    public int updateTextureIfNeeds(float [] matrix) {
//        Log.i(TAG,"updateTextureIfNeeds textid:"+_glTexId);

        try {
            synchronized (this) {
//                if (needsUpdateSurface) {
//                    Log.v(TAG,"updateTexImage: texid:"+_glTexId);
                    surfaceTexture.updateTexImage();
                    surfaceTexture.getTransformMatrix(matrix);

                    needsUpdateSurface = false;

                    return 1;
//                }
            }

        } catch (Throwable t) {

        }
        finally {

        }

        return 0;
    }

    public void setTargetViewDirty() {
        isTargetDirty = true;
    }

    private void createTargetViewOnUiThread() {

        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                View target = onCreateTargetView(mActivity);
                mTarget = target;

                boolean shouldShowPopup = false;
                if (_popUp == null) {
                    _popUp = new PopupWindow(mActivity);

                    _popUp.setWindowLayoutMode(ViewGroup.LayoutParams.WRAP_CONTENT,ViewGroup.LayoutParams.WRAP_CONTENT);
                    _popUp.setClippingEnabled(true);
                    _popUp.setBackgroundDrawable(new ColorDrawable(android.graphics.Color.TRANSPARENT));
                    _popUp.setTouchable(false);
                    _popUp.setFocusable(true);
                    _popUp.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);

                    LinearLayout layout = new LinearLayout(mActivity);

                    layout.setOrientation(LinearLayout.VERTICAL);

                    _popUp.setContentView(layout);
                    _windowContentLayout = layout;
                    shouldShowPopup = true;

                }

                LinearLayout layout = _windowContentLayout;
                ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(mWidth,mHeight);
                _layoutParams = params;

                layout.addView(target, params);

                if (shouldShowPopup) {
                    LinearLayout mainLayout = new LinearLayout(mActivity);

                    _popUp.showAtLocation(mainLayout, Gravity.BOTTOM,0,0);
                }
                _popUp.update();

                synchronized (this) {
                    this.notify() ;
                }

            }
        };

        runOnUiThreadAndWait(aRunnable);
    }

    public void simulateTouch(long eventTime, long downTime, int action, long x, long y) {
        int location[] = {0,0};
        mTarget.getLocationOnScreen(location);

        float fx = x + location[0];
        float fy = y + location[1];

        int metaState = 0;
        final MotionEvent event = MotionEvent.obtain(downTime,
                eventTime,
                action,
                fx,
                fy,
                metaState);
        Matrix m = new Matrix();
        m.setTranslate(-location[0],-location[1]);
        event.transform(m);

        dispatchEvent(event);
    }

    public void dispatchEvent(android.view.MotionEvent event) {
        final MotionEvent aEvent = event;
        Runnable aRunnable = new Runnable() {
            @Override
            public void run() {
                mTarget.dispatchTouchEvent(aEvent);
            }
        };

        mActivity.runOnUiThread(aRunnable);
    }
}
