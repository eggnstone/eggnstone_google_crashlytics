# eggnstone_google_crashlytics

A wrapper for Google Crashlytics. Allows to report via Firebase.

[![pub package](https://img.shields.io/pub/v/eggnstone_google_crashlytics.svg)](https://pub.dartlang.org/packages/eggnstone_google_crashlytics)
[![GitHub Issues](https://img.shields.io/github/issues/eggnstone/eggnstone_google_crashlytics.svg)](https://github.com/eggnstone/eggnstone_google_crashlytics/issues)
[![GitHub Stars](https://img.shields.io/github/stars/eggnstone/eggnstone_google_crashlytics.svg)](https://github.com/eggnstone/eggnstone_google_crashlytics/stargazers)


## Android: For Crashlytics to work add the following

- Add at the bottom of ```android/build.gradle```
```
apply plugin: 'com.google.gms.google-services'
```

- In ```android/app/build.gradle``` add the following to ```buildscript / dependencies```
```
classpath 'com.google.gms:google-services:4.3.12'
```
