import 'dart:async';

import 'package:eggnstone_dart/eggnstone_dart.dart';
import 'package:flutter/widgets.dart';

import 'FakeFirebaseCrashlytics.dart';
import 'IGoogleCrashlyticsService.dart';

typedef CrashReporterCallback = Function(Map<String, Object> params);

class GoogleCrashlyticsService
    implements IGoogleCrashlyticsService
{
    final FakeFirebaseCrashlytics _fakeFirebaseCrashlytics;
    final CrashReporterCallback? _additionalCrashReporterCallback;

    late bool _isEnabled;

    bool _isDebugEnabled;

    GoogleCrashlyticsService._internal(this._fakeFirebaseCrashlytics, this._additionalCrashReporterCallback, this._isEnabled, this._isDebugEnabled);

    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleCrashlyticsService> create(CrashReporterCallback? alternativeCrashReporterCallback, bool startEnabled, bool startDebugEnabled)
    => GoogleCrashlyticsService.createMockable(FakeFirebaseCrashlytics(startDebugEnabled: startDebugEnabled), alternativeCrashReporterCallback, startEnabled, startDebugEnabled);

    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleCrashlyticsService> createMockable(FakeFirebaseCrashlytics crashlytics, CrashReporterCallback? alternativeCrashReporterCallback, bool startEnabled, bool startDebugEnabled)
    async
    {
        final GoogleCrashlyticsService instance = GoogleCrashlyticsService._internal(crashlytics, alternativeCrashReporterCallback, startEnabled, startDebugEnabled);
        instance._init();
        return instance;
    }

    @override
    bool get isDebugEnabled
    => _isDebugEnabled;

    @override
    set isDebugEnabled(bool newValue)
    {
        _isDebugEnabled = newValue;
        _fakeFirebaseCrashlytics.isDebugEnabled = newValue;
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
                    _fakeFirebaseCrashlytics.recordFlutterError(details);
                    logInfo('# GoogleCrashlyticsService/FlutterError.onError/_fakeFirebaseCrashlytics.recordFlutterError succeeded.');
                }
                catch (e2, stackTrace2)
                {
                    logError('##################################################');
                    logError('# GoogleCrashlyticsService/FlutterError.onError/_fakeFirebaseCrashlytics.recordFlutterError failed!');
                    logError(e2.toString());
                    logError(stackTrace2.toString());
                    logError('##################################################');
                }

                if (_additionalCrashReporterCallback != null)
                {
                    final Map<String, Object> map =
                    <String, Object>{
                        'Exception': details.exception.toString(),
                        'CrashlyticsSource': 'GoogleCrashlyticsService/FlutterError.onError',
                        if (details.stack != null) 'StackTrace': details.stack.toString()
                    };

                    try
                    {
                        _additionalCrashReporterCallback!(map);
                        logInfo('# GoogleCrashlyticsService/FlutterError.onError/_additionalCrashReporterCallback succeeded.');
                    }
                    catch (e2, stackTrace2)
                    {
                        logError('##################################################');
                        logError('# GoogleCrashlyticsService/FlutterError.onError/_additionalCrashReporterCallback failed!');
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
        runZonedGuarded<void>(()
        {
            runApp(app);
        }, onError);
    }

    @override
    void onError(Object error, StackTrace stackTrace)
    {
        logError('##################################################');
        logError('# GoogleCrashlyticsService.onError');
        logError(error.toString());
        logError(stackTrace.toString());
        logError('##################################################');

        if (_isEnabled)
        {
            try
            {
                _fakeFirebaseCrashlytics.recordError(error, stackTrace);
                logInfo('# GoogleCrashlyticsService.onError/_fakeFirebaseCrashlytics.recordError succeeded.');
            }
            catch (e2, stackTrace2)
            {
                logError('##################################################');
                logError('# GoogleCrashlyticsService.onError/_fakeFirebaseCrashlytics.recordError failed!');
                logError(e2.toString());
                logError(stackTrace2.toString());
                logError('##################################################');
            }

            if (_additionalCrashReporterCallback != null)
            {
                final Map<String, Object> map =
                <String, Object>{
                    'Error': error.toString(),
                    'CrashlyticsSource': 'GoogleCrashlyticsService.onError'
                };

                map['StackTrace'] = stackTrace.toString();

                try
                {
                    _additionalCrashReporterCallback!(map);
                    logInfo('# GoogleCrashlyticsService.onError/_additionalCrashReporterCallback succeeded.');
                }
                catch (e2, stackTrace2)
                {
                    logError('##################################################');
                    logError('# GoogleCrashlyticsService.onError/_additionalCrashReporterCallback failed!');
                    logError(e2.toString());
                    logError(stackTrace2.toString());
                    logError('##################################################');
                }
            }
        }
    }

    @override
    void setUserId(String value)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleCrashlytics' : 'Disabled-GoogleCrashlytics') + ': setUserId: $value');

        if (_isEnabled)
            _fakeFirebaseCrashlytics.setUserIdentifier(value);
    }

    @override
    void setUserProperty(String key, String value)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleCrashlytics' : 'Disabled-GoogleCrashlytics') + ': setUserProperty: key=$key value=$value');

        if (_isEnabled)
            _fakeFirebaseCrashlytics.setCustomKey(key, value);
    }

    @override
    void recordError(Object error, StackTrace stackTrace)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleCrashlytics' : 'Disabled-GoogleCrashlytics') + ': recordError: error=$error stackTrace=$stackTrace');

        if (_isEnabled)
            _fakeFirebaseCrashlytics.recordError(error, stackTrace);
    }
}
