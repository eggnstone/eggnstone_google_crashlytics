# eggnstone_google_crashlytics

A wrapper for Google Crashlytics. Allows to report via Firebase.

## Android: For Crashlytics to work add the following

- Add at the bottom of ```android/build.gradle```
```
apply plugin: 'com.google.gms.google-services'
```

- In ```android/app/build.gradle``` add the following to ```buildscript / dependencies```
```
classpath 'com.google.gms:google-services:4.3.12'
```
