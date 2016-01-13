package org.tiny4.UIKitDemo;

import org.tiny4.CocoaActivity.CocoaActivity;

import android.app.Activity;
import android.os.Bundle;

import android.app.NativeActivity;
import android.content.res.Configuration;

import android.widget.RelativeLayout;
	
public class MainActivity extends CocoaActivity
{
    static
    {
        System.loadLibrary ("gnustl_shared");
        System.loadLibrary ("dispatch");
        System.loadLibrary ("objc");
        System.loadLibrary ("gnustep-base");
        System.loadLibrary ("gnustep-corebase");
        System.loadLibrary ("AVFoundation");
        System.loadLibrary ("TNJavaHelper");
        System.loadLibrary ("CoreGraphics");
        System.loadLibrary ("CoreText");
        System.loadLibrary ("GLESv2");
        System.loadLibrary ("OpenGLES");
        System.loadLibrary ("QuartzCore");
        System.loadLibrary ("UIKit");
        System.loadLibrary ("MediaPlayer");
        System.loadLibrary ("UIKitDemo");
    }
    
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }
}
