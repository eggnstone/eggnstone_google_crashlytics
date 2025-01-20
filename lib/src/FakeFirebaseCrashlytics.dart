import 'dart:io';

import 'package:eggnstone_dart/eggnstone_dart.dart';
import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:flutter/foundation.dart';

class FakeFirebaseCrashlytics
{
    static const String CRASHLYTICS_ERROR = 'CrashlyticsError';
    static const String CRASHLYTICS_FLUTTER_ERROR = 'CrashlyticsFlutterError';

    String? _userIdentifier;
    final Map<String, String> _customData = <String, String>{};

    bool isDebugEnabled;
    IAnalyticsService? analyticsService;

    FakeFirebaseCrashlytics({required bool startDebugEnabled, required this.analyticsService})
        : isDebugEnabled = startDebugEnabled;

    void recordFlutterError(FlutterErrorDetails details)
    {
        if (analyticsService == null)
        {
            logWarning('FakeFirebaseCrashlytics.recordFlutterError: Cannot record Flutter error because IAnalyticsService not registered.');
            return;
        }

        final DiagnosticsNode? context = details.context;
        final String? contextText = context is ErrorDescription ? context.value.toString() : null;

        final Map<String, Object> map =
            <String, Object>
            {
                if (contextText != null) 'Context': contextText,
                'Error': details.exception.toString(),
                if (details.library != null) 'Library': details.library!,
                if (details.stack != null) 'StackTrace': details.stack.toString(),
                'Platform': kIsWeb ? 'Web' : Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : '<unknown>',
                if (_userIdentifier != null) 'UserId': _userIdentifier!
            };

        map.addAll(_customData.map<String, Object>((String key, Object value)
                // ignore: prefer_interpolation_to_compose_strings
                => MapEntry<String, Object>('Custom_' + key, value)));

        if (isDebugEnabled)
            logInfo('FakeFirebaseCrashlytics.recordFlutterError: calling IAnalyticsService.track ...');
        analyticsService!.track(CRASHLYTICS_FLUTTER_ERROR, map);
        if (isDebugEnabled)
            logInfo('FakeFirebaseCrashlytics.recordFlutterError: called IAnalyticsService.track.');
    }

    void recordError(Object error, StackTrace stackTrace)
    {
        if (analyticsService != null)
        {
            final Map<String, Object> map =
                <String, Object>
                {
                    'Error': error.toString(),
                    'StackTrace': stackTrace.toString(),
                    'Platform': kIsWeb ? 'Web' : Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : '<unknown>',
                    if (_userIdentifier != null) 'UserId': _userIdentifier!
                };

            map.addAll(_customData.map<String, Object>((String key, Object value)
                    // ignore: prefer_interpolation_to_compose_strings
                    => MapEntry<String, Object>('Custom_' + key, value)));

            if (isDebugEnabled)
                logInfo('FakeFirebaseCrashlytics.recordError: calling IAnalyticsService.track ...');
            analyticsService!.track(CRASHLYTICS_ERROR, map);
            if (isDebugEnabled)
                logInfo('FakeFirebaseCrashlytics.recordError: called IAnalyticsService.track.');
        }
        else
            logWarning('FakeFirebaseCrashlytics.recordError: Cannot record error because IAnalyticsService not registered.');
    }

    // ignore: use_setters_to_change_properties
    void setUserIdentifier(String value)
    {
        _userIdentifier = value;
    }

    void setCustomKey(String key, String value)
    {
        _customData[key] = value;
    }
}
