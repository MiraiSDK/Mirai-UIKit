package org.tiny4.CocoaActivity;

import android.app.Activity;
import android.view.OrientationEventListener;
import android.content.Context;
import android.content.pm.ActivityInfo;

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

    private native boolean nativeAllowOrientationChangeTo(int orrientationInfo);

    private native void nativeChangeOrientationTo(int orrientationInfo);

    public static ScreenOrientationHandler instance() {
        if (_instance == null) {
            throw new RuntimeException("ScreenOrintation's instance not init.");
        }
        return _instance;
    }

    public static void setScreenOrientationInfo(final int orrientationInfo) {
        final ScreenOrientationHandler instance = instance();
        instance._mainActivity.runOnUiThread(new Runnable() {
            public void run() {
                instance.changeOrientationInfoTo(orrientationInfo);
            }
        });
    }
    
    private ScreenOrientationHandler(Activity mainActivity, int rate) {
        super(mainActivity, rate);
        _mainActivity = mainActivity;
        _mainActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LOCKED);
    }


    public void onResume() {
        enable();
        onOrientationChanged(_mainActivity.getResources().getConfiguration().orientation);
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

    private void tryToChangeOrientationTo(int orrientationInfo) {

        if (_lastGetOrientationInfo != orrientationInfo) {
            
            if (nativeAllowOrientationChangeTo(orrientationInfo)) {
                changeOrientationInfoTo(orrientationInfo);
            }
            _lastGetOrientationInfo = orrientationInfo;
        }
    }
    
    private void changeOrientationInfoTo(int orrientationInfo) {
        
        if (_currentOrientationInfo != orrientationInfo) {
            _currentOrientationInfo = orrientationInfo;
            
            _mainActivity.setRequestedOrientation(orrientationInfo);
            _mainActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LOCKED);
            nativeChangeOrientationTo(orrientationInfo);
        }
    }
}