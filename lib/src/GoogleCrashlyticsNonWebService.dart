import 'dart:async';

import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

import 'IGoogleCrashlyticsService.dart';

typedef CrashReporterCallback = Function(Map<String, dynamic> params);

class GoogleCrashlyticsService
    implements IGoogleCrashlyticsService
{
    final FirebaseCrashlytics _firebaseCrashlytics;
    final CrashReporterCallback? _additionalCrashReporterCallback;

    bool _isEnabled;
    bool _isDebugEnabled;

    GoogleCrashlyticsService._internal(this._firebaseCrashlytics, this._additionalCrashReporterCallback, this._isEnabled, this._isDebugEnabled);

    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleCrashlyticsService> create(CrashReporterCallback? alternativeCrashReporterCallback, bool startEnabled, bool startDebugEnabled)
    => GoogleCrashlyticsService.createMockable(FirebaseCrashlytics.instance, alternativeCrashReporterCallback, startEnabled, startDebugEnabled);

    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleCrashlyticsService> createMockable(FirebaseCrashlytics crashlytics, CrashReporterCallback? alternativeCrashReporterCallback, bool startEnabled, bool startDebugEnabled)
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
        //_firebaseCrashlytics.isDebugEnabled = newValue;
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
                    logInfo('# GoogleCrashlyticsService/FlutterError.onError/_firebaseCrashlytics.recordFlutterError succeeded.');
                }
                catch (e2, stackTrace2)
                {
                    logError('##################################################');
                    logError('# GoogleCrashlyticsService/FlutterError.onError/_firebaseCrashlytics.recordFlutterError failed!');
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
                _firebaseCrashlytics.recordError(error, stackTrace);
                logInfo('# GoogleCrashlyticsService.onError/_firebaseCrashlytics.recordError succeeded.');
            }
            catch (e2, stackTrace2)
            {
                logError('##################################################');
                logError('# GoogleCrashlyticsService.onError/_firebaseCrashlytics.recordError failed!');
                logError(e2.toString());
                logError(stackTrace2.toString());
                logError('##################################################');
            }

            if (_additionalCrashReporterCallback != null)
            {
                final Map<String, dynamic> map =
                <String, dynamic>{
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

    @override
    void recordError(Object error, StackTrace stackTrace)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleCrashlytics' : 'Disabled-GoogleCrashlytics') + ': recordError: error=$error stackTrace=$stackTrace');

        if (_isEnabled)
            _firebaseCrashlytics.recordError(error, stackTrace);
    }
}
