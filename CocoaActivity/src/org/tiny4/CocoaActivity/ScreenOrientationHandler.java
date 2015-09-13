package org.tiny4.CocoaActivity;

import android.app.Activity;
import android.view.OrientationEventListener;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.view.Surface;

import android.util.Log;

public class ScreenOrientationHandler extends OrientationEventListener {

    private static ScreenOrientationHandler _instance;

    private final Activity _mainActivity;
    private int _lastGetOrientationInfo = -1;
    private int _currentOrientationInfo = -1;

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
        
        int rotation = _mainActivity.getWindowManager().getDefaultDisplay().getRotation();
        int orientationInfo = normalizeScreenRotation(rotation);
        nativeInitOrientation(orientationInfo);
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

        if (orientation >= 315 || orientation < 45) {
            return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;

        } else if (orientation >= 45 && orientation < 135) {
            return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;

        } else if (orientation >= 135 && orientation < 225 ) {
            return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;

        } else {
            return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
        }
    }

    private int normalizeScreenRotation(int rotation) {
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