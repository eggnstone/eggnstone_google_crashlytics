# eggnstone_google_crashlytics

Google Crashlytics wrapper. Allows to report via Firebase.

# For Crashlytics to work add the following
- In ```android/build.gradle``` add the following to ```buildscript / repositories```
```
maven {
    url 'https://maven.fabric.io/public'
}
```

- In ```android/app/build.gradle``` add the following to ```buildscript / dependencies```
```
classpath 'com.google.gms:google-services:4.3.3'
classpath 'io.fabric.tools:gradle:1.31.2'
```
    
- Add at the bottom of ```android/build.gradle```
```
apply plugin: 'io.fabric'
apply plugin: 'com.google.gms.google-services'
```
