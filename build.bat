set PLATFORM=%ANDROID_HOME%\platforms\android-25
set BUILD_TOOLS=%ANDROID_HOME%\build-tools\25.0.3
set APPNAME=androidboot

set ARM_TOOLCHAIN=%ANDROID_NDK%\toolchains\aarch64-linux-android-4.9\prebuilt\windows-x86_64\bin

set CC_ARM=%ARM_TOOLCHAIN%\aarch64-linux-android-gcc.exe


mkdir build build\gen build\obj build\apk


"%BUILD_TOOLS%\aapt.exe" package -f -m -J build/gen/ -S res -M java\AndroidManifest.xml -I "%PLATFORM%\android.jar"

javac -source 1.7 -target 1.7 -bootclasspath "%JAVA_HOME%\jre\lib\rt.jar" -classpath "%PLATFORM%\android.jar" -d build\obj build\gen\com\scatteredray\%APPNAME%\R.java java\MainActivity.java

call "%BUILD_TOOLS%\dx.bat" --dex --output=build\apk\classes.dex build\obj

@echo on

REM %CC_ARM% --sysroot="%ANDROID_NDK%\platforms\android-27\arch-arm64" -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wl,--fix-cortex-a8 -fPIC -shared -o build\apk\lib\armeabi-v7a/lib%APPNAME%.so src\main.cpp

REM %CC_ARM% --sysroot="%ANDROID_NDK%\platforms\android-27\arch-arm64" -march=armv7-a -Wl,--fix-cortex-a8 -fPIC -shared -o build\apk\lib\armeabi-v7a/lib%APPNAME%.so src\main.cpp

REM %CC_ARM% --sysroot="%ANDROID_NDK%\platforms\android-27\arch-arm64" -Wl,--fix-cortex-a8 -fPIC -shared -o build\apk\lib\armeabi-v7a/lib%APPNAME%.so src\main.cpp

%CC_ARM% --sysroot="%ANDROID_NDK%\sysroot" -Wl,--fix-cortex-a8 -fPIC -shared -o build\apk\lib\armeabi-v7a/lib%APPNAME%.so src\main.cpp

"%BUILD_TOOLS%\aapt.exe" package -f -M java\AndroidManifest.xml -S res -I "%PLATFORM%\android.jar" -F build\%APPNAME%.unsigned.apk build\apk

"%BUILD_TOOLS%\zipalign.exe" -f -p 4 build\%APPNAME%.unsigned.apk build\%APPNAME%.aligned.apk

call "%BUILD_TOOLS%\apksigner.bat" sign --ks keystore.jks --ks-key-alias androidkey --ks-pass pass:android --key-pass pass:android --out build/%APPNAME%.apk build/%APPNAME%.aligned.apk

@echo on