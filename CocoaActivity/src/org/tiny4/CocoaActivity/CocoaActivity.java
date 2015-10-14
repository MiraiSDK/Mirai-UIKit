package org.tiny4.CocoaActivity;

import android.os.Bundle;
import android.app.Activity;
import android.app.NativeActivity;
import android.hardware.SensorManager;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;

import android.util.Log;

public class CocoaActivity extends NativeActivity
{
    private static String TAG = "CocoaActivity";
    
    public native int nativeSupportedOrientation(int orientation);
    
    private native void nativeSupportedDensity(float density);
    
    private native void nativeOnTrimMemory(int level);

    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        nativeSupportedDensity(getResources().getDisplayMetrics().density);
        ScreenOrientationHandler.initInstance(this, SensorManager.SENSOR_DELAY_NORMAL);
    }

    public void onDestroy() {
        super.onDestroy();
        ScreenOrientationHandler.clearInstance();
    }

    public void onPause() {
        super.onResume();
        ScreenOrientationHandler.instance().onPause();
    }

    public void onResume() {
        super.onPause();
        ScreenOrientationHandler.instance().onResume();
    }

    public void onConfigurationChanged (Configuration newConfig)
    {
        super.onConfigurationChanged (newConfig);
    }

	@Override
    public void onTrimMemory (int level)
    {
        Log.i(TAG,"onTrimMemory:"+ level);
        nativeOnTrimMemory(level);
    }
}
