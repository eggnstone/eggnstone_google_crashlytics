import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class FakeFirebaseCrashlytics
{
    static const String CRASHLYTICS_ERROR = 'CrashlyticsError';
    static const String CRASHLYTICS_FLUTTER_ERROR = 'CrashlyticsFlutterError';

    String? _userIdentifier;
    final Map<String, String> _customData = <String, String>{};

    bool isDebugEnabled;

    FakeFirebaseCrashlytics({required bool startDebugEnabled}) :
            isDebugEnabled = startDebugEnabled;

    void recordFlutterError(FlutterErrorDetails details)
    {
        if (GetIt.instance.isRegistered<IAnalyticsService>())
        {
            final Map<String, dynamic> map =
            <String, dynamic>{
                'Error': details.exception.toString(),
                if (details.stack != null) 'StackTrace': details.stack.toString(),
                'Platform': kIsWeb ? 'Web' : 'Android',
                if (_userIdentifier != null) 'UserId': _userIdentifier,
            };

            map.addAll(_customData.map<String, dynamic>((String key, dynamic value)
            // ignore: prefer_interpolation_to_compose_strings
            => MapEntry<String, dynamic>('Custom_' + key, value)));

            if (isDebugEnabled)
                logInfo('FakeFirebaseCrashlytics.recordFlutterError: calling IAnalyticsService.track ...');
            GetIt.instance.get<IAnalyticsService>().track(CRASHLYTICS_FLUTTER_ERROR, map);
            if (isDebugEnabled)
                logInfo('FakeFirebaseCrashlytics.recordFlutterError: called IAnalyticsService.track.');
        }
        else
            logWarning('FakeFirebaseCrashlytics.recordFlutterError: Cannot record Flutter error because IAnalyticsService not registered.');
    }

    void recordError(Object error, StackTrace stackTrace)
    {
        if (GetIt.instance.isRegistered<IAnalyticsService>())
        {
            final Map<String, dynamic> map =
            <String, dynamic>{
                'Error': error.toString(),
                'StackTrace': stackTrace.toString(),
                'Platform': kIsWeb ? 'Web' : 'Android',
                if (_userIdentifier != null) 'UserId': _userIdentifier,
            };

            map.addAll(_customData.map<String, dynamic>((String key, dynamic value)
            // ignore: prefer_interpolation_to_compose_strings
            => MapEntry<String, dynamic>('Custom_' + key, value)));

            if (isDebugEnabled)
                logInfo('FakeFirebaseCrashlytics.recordError: calling IAnalyticsService.track ...');
            GetIt.instance.get<IAnalyticsService>().track(CRASHLYTICS_ERROR, map);
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
