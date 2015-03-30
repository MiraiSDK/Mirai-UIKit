#!/bin/bash

checkError()
{
    if [ "${1}" -ne "0" ]; then
        echo "*** Error: ${2}"
        exit ${1}
    fi
}

#create a empty availability
if [ ! -f $MIRAI_SDK_PREFIX/include/Availability.h ]; then
	touch $MIRAI_SDK_PREFIX/include/Availability.h
fi

if [ ! -f $MIRAI_SDK_PREFIX/lib/libTNJavaHelper.so ]; then
	pushd $MIRAI_PROJECT_ROOT_PATH/Mirai-UIKit/TNJavaHelper
	xcodebuild -target TNJavaHelper-Android -xcconfig xcconfig/Android-$ABI.xcconfig
	checkError $? "build JavaHelper failed"
	
	#clean up
	rm -r build
	popd
fi

if [ ! -f $MIRAI_SDK_PREFIX/lib/libUIKit.so ]; then
	pushd $MIRAI_PROJECT_ROOT_PATH/Mirai-UIKit
	xcodebuild -target UIKit -xcconfig xcconfig/Android-$ABI.xcconfig
	checkError $? "build UIKit failed"
	
	#clean up
	rm -r build
	popd
fi