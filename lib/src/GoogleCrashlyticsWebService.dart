import 'dart:async';

import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'IGoogleCrashlyticsService.dart';

typedef CrashReporterCallback = Function(Map<String, dynamic> params);

class GoogleCrashlyticsService
    implements IGoogleCrashlyticsService
{
    final FakeFirebaseCrashlytics _firebaseCrashlytics;
    final CrashReporterCallback? _additionalCrashReporterCallback;

    bool _isEnabled;

    GoogleCrashlyticsService._internal(this._firebaseCrashlytics, this._additionalCrashReporterCallback, this._isEnabled);

    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleCrashlyticsService> create(CrashReporterCallback? alternativeCrashReporterCallback, bool startEnabled)
    => GoogleCrashlyticsService.createMockable(FakeFirebaseCrashlytics(), alternativeCrashReporterCallback, startEnabled);

    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleCrashlyticsService> createMockable(FakeFirebaseCrashlytics crashlytics, CrashReporterCallback? alternativeCrashReporterCallback, bool startEnabled)
    async
    {
        final GoogleCrashlyticsService instance = GoogleCrashlyticsService._internal(crashlytics, alternativeCrashReporterCallback, startEnabled);
        instance._init();
        return instance;
    }

    void _init()
    {
        FlutterError.onError = (FlutterErrorDetails details)
        {
            logError('##################################################');
            logError('# GoogleCrashlyticsService/FlutterError.onError ');

            if (isLoggerEnabled)
            {
                // TODO: move to LogTools
                FlutterError.dumpErrorToConsole(details);
            }

            if (details.stack == null)
                logError('No stacktrace available.');
            else
                logError(details.stack.toString());

            logError('##################################################');

            if (_isEnabled)
            {
                try
                {
                    _firebaseCrashlytics.recordFlutterError(details);
                }
                catch (e2, stackTrace2)
                {
                    logError('##################################################');
                    logError('# GoogleCrashlyticsService/FlutterError.onError/_crashlytics.recordFlutterError');
                    logError(e2.toString());
                    logError(stackTrace2.toString());
                    logError('##################################################');
                }

                if (_additionalCrashReporterCallback != null)
                {
                    final Map<String, dynamic> map =
                    <String, dynamic>{
                        'Exception': details.exception.toString(),
                        'CrashlyticsSource': 'GoogleCrashlyticsService/FlutterError.onError',
                        if (details.stack != null) 'StackTrace': details.stack.toString()
                    };

                    try
                    {
                        _additionalCrashReporterCallback!(map);
                    }
                    catch (e2, stackTrace2)
                    {
                        logError('##################################################');
                        logError('# GoogleCrashlyticsService/FlutterError.onError/_additionalCrashReporterCallback');
                        logError(e2.toString());
                        logError(stackTrace2.toString());
                        logError('##################################################');
                    }
                }
            }
        };
    }

    // ignore: use_setters_to_change_properties, avoid_positional_boolean_parameters
    void setEnabled(bool newValue)
    => _isEnabled = newValue;

    @override
    void run(Widget app)
    {
        runZonedGuarded<Future<void>>(
                ()
            async
            {
                runApp(app);
            },
                (Object error, StackTrace stackTrace)
            {
                logError('##################################################');
                logError('# GoogleCrashlyticsService.run/runZoned/onError');
                logError(error.toString());
                logError(stackTrace.toString());
                logError('##################################################');

                if (_isEnabled)
                {
                    try
                    {
                        _firebaseCrashlytics.recordError(error, stackTrace);
                    }
                    catch (e2, stackTrace2)
                    {
                        logError('##################################################');
                        logError('# GoogleCrashlyticsService.run/runZoned/onError/_crashlytics.recordError');
                        logError(e2.toString());
                        logError(stackTrace2.toString());
                        logError('##################################################');
                    }

                    if (_additionalCrashReporterCallback != null)
                    {
                        final Map<String, dynamic> map =
                        <String, dynamic>{
                            'Error': error.toString(),
                            'CrashlyticsSource': 'GoogleCrashlyticsService.run/runZoned/onError'
                        };

                        map['StackTrace'] = stackTrace.toString();

                        try
                        {
                            _additionalCrashReporterCallback!(map);
                        }
                        catch (e2, stackTrace2)
                        {
                            logError('##################################################');
                            logError('# GoogleCrashlyticsService.run/runZoned/onError/_additionalCrashReporterCallback');
                            logError(e2.toString());
                            logError(stackTrace2.toString());
                            logError('##################################################');
                        }
                    }
                }
            });
    }

    @override
    void setUserId(String value)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleCrashlytics' : 'Disabled-GoogleCrashlytics') + ': setUserId: $value');

        if (_isEnabled)
            _firebaseCrashlytics.setUserIdentifier(value);
    }

    @override
    void setUserProperty(String key, String value)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleCrashlytics' : 'Disabled-GoogleCrashlytics') + ': setUserProperty: key=$key value=$value');

        if (_isEnabled)
            _firebaseCrashlytics.setCustomKey(key, value);
    }
}

class FakeFirebaseCrashlytics
{
    static const String CRASHLYTICS_ERROR = 'CrashlyticsError';
    static const String CRASHLYTICS_FLUTTER_ERROR = 'CrashlyticsFlutterError';

    String? _userIdentifier;
    final Map<String, String> _customData = <String, String>{};

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

            GetIt.instance.get<IAnalyticsService>().track(CRASHLYTICS_FLUTTER_ERROR, map);
        }
    }

    void recordError(Object error, StackTrace stackTrace)
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

        GetIt.instance.get<IAnalyticsService>().track(CRASHLYTICS_ERROR, map);
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
