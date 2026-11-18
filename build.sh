#!/bin/bash
# สร้างโปรเจกต์ Android จาก index.html + icon.png ให้อัตโนมัติ
set -e
rm -rf proj
mkdir -p "$(dirname proj/settings.gradle)"
cat > proj/settings.gradle <<'KITEOF'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS); repositories { google(); mavenCentral() } }
rootProject.name = "NakponGame"
include ':app'
KITEOF
mkdir -p "$(dirname proj/build.gradle)"
cat > proj/build.gradle <<'KITEOF'
plugins { id 'com.android.application' version '8.7.3' apply false }
KITEOF
mkdir -p "$(dirname proj/gradle.properties)"
cat > proj/gradle.properties <<'KITEOF'
org.gradle.jvmargs=-Xmx2048m
android.useAndroidX=true
KITEOF
mkdir -p "$(dirname proj/app/build.gradle)"
cat > proj/app/build.gradle <<'KITEOF'
plugins { id 'com.android.application' }
android {
    namespace 'th.nakpon.game'
    compileSdk 34
    defaultConfig {
        applicationId "th.nakpon.game"
        minSdk 24
        targetSdk 34
        versionCode 7
        versionName "7.0"
    }
    buildTypes {
        release { minifyEnabled false }
    }
    compileOptions { sourceCompatibility JavaVersion.VERSION_17; targetCompatibility JavaVersion.VERSION_17 }
}
KITEOF
mkdir -p "$(dirname proj/app/src/main/AndroidManifest.xml)"
cat > proj/app/src/main/AndroidManifest.xml <<'KITEOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:allowBackup="true"
        android:hardwareAccelerated="true"
        android:theme="@style/AppTheme">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:screenOrientation="sensorLandscape"
            android:configChanges="orientation|screenSize|keyboardHidden|smallestScreenSize|screenLayout">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
KITEOF
mkdir -p "$(dirname proj/app/src/main/res/values/strings.xml)"
cat > proj/app/src/main/res/values/strings.xml <<'KITEOF'
<resources><string name="app_name">นากปอน กรีดยางผี</string></resources>
KITEOF
mkdir -p "$(dirname proj/app/src/main/res/values/styles.xml)"
cat > proj/app/src/main/res/values/styles.xml <<'KITEOF'
<resources>
    <style name="AppTheme" parent="android:Theme.Material.NoActionBar">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:windowFullscreen">true</item>
        <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
    </style>
</resources>
KITEOF
mkdir -p "$(dirname proj/app/src/main/java/th/nakpon/game/MainActivity.java)"
cat > proj/app/src/main/java/th/nakpon/game/MainActivity.java <<'KITEOF'
package th.nakpon.game;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends Activity {
    private WebView web;

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        web = new WebView(this);
        web.setBackgroundColor(0xFF000000);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);          // เซฟเงิน/คลาสด้วย localStorage
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setAllowFileAccess(true);
        web.setWebViewClient(new WebViewClient());
        setContentView(web);
        web.loadUrl("file:///android_asset/index.html");
        hideBars();
    }

    private void hideBars() {
        getWindow().getDecorView().setSystemUiVisibility(
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN
            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
    }

    @Override public void onWindowFocusChanged(boolean f) { super.onWindowFocusChanged(f); if (f) hideBars(); }
    @Override protected void onPause() { super.onPause(); web.onPause(); }
    @Override protected void onResume() { super.onResume(); web.onResume(); }
    @Override public void onBackPressed() { moveTaskToBack(true); }
}
KITEOF
mkdir -p proj/app/src/main/assets
cp index.html proj/app/src/main/assets/index.html
for d in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  n=${d%%:*}; s=${d##*:}
  mkdir -p proj/app/src/main/res/mipmap-$n
  convert icon.png -resize ${s}x${s} proj/app/src/main/res/mipmap-$n/ic_launcher.png
done
echo "project ready"
