# eggnstone_google_crashlytics

A wrapper for Google Crashlytics

# For Crashlytics to work add the following
- Add in android/build.gradle to buildscript / repositories
maven {
    url 'https://maven.fabric.io/public'
}

- Add in android/app/build.gradle to buildscript / dependencies
    classpath 'com.google.gms:google-services:4.3.0'
    classpath 'io.fabric.tools:gradle:1.26.1'
    
- Add at the bottom of android/build.gradle
apply plugin: 'io.fabric'
apply plugin: 'com.google.gms.google-services'
