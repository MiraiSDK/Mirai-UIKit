#UIApplicationMain做了什么

* take ``argc`` and ``argv`` arguments, configure enviroment
* take ``principalClassName`` argument, init UIApplication object
* take ``delegateClassName`` argument, init delegate object
* run application object


* setup main event loop
* processing events
* load Info.plist

--- 

##ass

* check arguments
* call BKSDisplayServicesStart()
* call UIApplicationInitialize()
* load info.plist
	* check key: ``NSPrincipalClass``
* call GSEventRegisterEventCallBack()
* call BKSHIDEventRegisterEventCallback()
* call GSEventInitialize()
* call GSEventPushRunLoopMode()
* call _startWindowServerIfNecessary
* call _startStatusBarServerIfNecessary
* call UIApplicationInstantiateSingleton()
* call [[FBSUIApplicationSystemService alloc] initWithQueue:]
* setDelegate
* [FBSUIApplicationWorkspace alloc]
* UIInitializationRunLoopMode

* [[UIDevice currentDevice] userInterfaceIdiom] 
* [UIApp run]
