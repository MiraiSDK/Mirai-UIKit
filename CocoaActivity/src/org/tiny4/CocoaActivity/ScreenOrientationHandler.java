package org.tiny4.CocoaActivity;

import android.app.Activity;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.OrientationEventListener;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.view.Surface;

import android.util.Log;

public class ScreenOrientationHandler extends OrientationEventListener {
    private static final String TAG = "CocoaActivity";

    private static ScreenOrientationHandler _instance;

    private final Activity _mainActivity;
    private int _lastGetOrientationInfo = -1;
    private int _currentOrientationInfo = -1;

    // 0 degree rotation, which is natural orientation
    // on some Table device, it maybe landscape
    private boolean _naturalOrientationIsLandscaped = false;

    public static void initInstance(Activity mainActivity, int rate) {

        if (_instance == null) {
            _instance = new ScreenOrientationHandler(mainActivity, rate);
        }
    }

    public static void clearInstance() {
        _instance = null;
    }

    private native void nativeInitOrientation(int orientationInfo);
    
    private native boolean nativeAllowOrientationChangeTo(int orientationInfo);

    private native void nativeChangeOrientationTo(int orientationInfo);

    public static ScreenOrientationHandler instance() {
        if (_instance == null) {
            throw new RuntimeException("ScreenOrintation's instance not init.");
        }
        return _instance;
    }

    public static void setScreenOrientationInfo(final int orientationInfo) {
        final ScreenOrientationHandler instance = instance();
        instance._mainActivity.runOnUiThread(new Runnable() {
            public void run() {
                instance.changeOrientationInfoTo(orientationInfo);
            }
        });
    }
    
    private ScreenOrientationHandler(Activity mainActivity, int rate) {
        super(mainActivity, rate);
        _mainActivity = mainActivity;
        _mainActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LOCKED);

        determineNaturalOrientation();

        int rotation = _mainActivity.getWindowManager().getDefaultDisplay().getRotation();
        int orientationInfo = normalizeScreenRotation(rotation);
        nativeInitOrientation(orientationInfo);
    }

    private void determineNaturalOrientation() {
        Display display = _mainActivity.getWindowManager().getDefaultDisplay();
        int rotation = display.getRotation();
        DisplayMetrics dm = new DisplayMetrics();
        display.getRealMetrics(dm);
        int width = dm.widthPixels;
        int height = dm.heightPixels;

        switch (rotation) {
            case Surface.ROTATION_0:
            case Surface.ROTATION_180:
                if (width > height) {
                    _naturalOrientationIsLandscaped = true;
                }
                break;
            case Surface.ROTATION_90:
            case Surface.ROTATION_270:
                if (width < height) {
                    _naturalOrientationIsLandscaped = true;
                }
                break;
            default:break;
        }
    }


    public void onResume() {
        enable();
        synchronizeToCurrentScreenRotation();
    }

    public void onPause() {
        disable();
    }

    public void onOrientationChanged(int orientation) {

        if (orientation == ORIENTATION_UNKNOWN) {
            return;
        }
        int orientationInfo = normalizeOrientationInfo(orientation);
        tryToChangeOrientationTo(orientationInfo);
    }
    
    private void synchronizeToCurrentScreenRotation() {
        
        _lastGetOrientationInfo = -1;
        int rotation = _mainActivity.getWindowManager().getDefaultDisplay().getRotation();
        int orientationInfo = normalizeScreenRotation(rotation);
        tryToChangeOrientationTo(orientationInfo);
    }
    
    private int normalizeOrientationInfo(int orientation) {

        int rotation = Surface.ROTATION_0;

        if (orientation >= 315 || orientation < 45) {
            rotation = Surface.ROTATION_0;

        } else if (orientation >= 45 && orientation < 135) {
            rotation = Surface.ROTATION_90;

        } else if (orientation >= 135 && orientation < 225 ) {
            rotation = Surface.ROTATION_180;

        } else {
            rotation = Surface.ROTATION_270;
        }

        return normalizeScreenRotation(rotation);
    }

    private int normalizeScreenRotation(int rotation) {
        if (_naturalOrientationIsLandscaped) {
            switch (rotation) {
                case Surface.ROTATION_0:
                    return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;

                case Surface.ROTATION_90:
                    return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;

                case Surface.ROTATION_180:
                    return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;

                case Surface.ROTATION_270:
                    return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
                default:
                    break;
            }

        } else {
            switch (rotation) {
                case Surface.ROTATION_0:
                    return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;

                case Surface.ROTATION_90:
                    return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;

                case Surface.ROTATION_180:
                    return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;

                case Surface.ROTATION_270:
                    return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
            }
        }
        Log.e(TAG,"Unknow screen rotaion:"+rotation);
        return -1;
    }
    
    private void tryToChangeOrientationTo(int orientationInfo) {
        
        if (_lastGetOrientationInfo != orientationInfo) {
            
            if (nativeAllowOrientationChangeTo(orientationInfo)) {
                changeOrientationInfoTo(orientationInfo);
            }
            _lastGetOrientationInfo = orientationInfo;
        }
    }
    
    private void changeOrientationInfoTo(int orientationInfo) {
        
        if (_currentOrientationInfo != orientationInfo) {
            _currentOrientationInfo = orientationInfo;
            
            _mainActivity.setRequestedOrientation(orientationInfo);
            _mainActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LOCKED);
            nativeChangeOrientationTo(orientationInfo);
        }
    }
}