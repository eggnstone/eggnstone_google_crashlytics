import 'dart:async';

import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:eggnstone_google_crashlytics/google/IGoogleCrashlyticsService.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

typedef CrashReporterCallback = Function(Map<String, dynamic> params);

class GoogleCrashlyticsService
    implements IGoogleCrashlyticsService
{
    final FirebaseCrashlytics _crashlytics;
    final CrashReporterCallback? _additionalCrashReporterCallback;

    bool _isEnabled;

    GoogleCrashlyticsService._internal(this._crashlytics, this._additionalCrashReporterCallback, this._isEnabled);

    static Future<IGoogleCrashlyticsService> create(CrashReporterCallback? alternativeCrashReporterCallback, bool startEnabled)
    => GoogleCrashlyticsService.createMockable(FirebaseCrashlytics.instance, alternativeCrashReporterCallback, startEnabled);

    static Future<IGoogleCrashlyticsService> createMockable(FirebaseCrashlytics crashlytics, CrashReporterCallback? alternativeCrashReporterCallback, bool startEnabled)
    async
    {
        var instance = GoogleCrashlyticsService._internal(crashlytics, alternativeCrashReporterCallback, startEnabled);
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
                    _crashlytics.recordFlutterError(details);
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
                    Map<String, dynamic> map =
                    {
                        'Exception': details.exception.toString(),
                        'CrashlyticsSource': 'GoogleCrashlyticsService/FlutterError.onError'
                    };

                    if (details.stack != null)
                        map['StackTrace'] = details.stack.toString();

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

    void setEnabled(bool newValue)
    => _isEnabled = newValue;

    void run(Widget app)
    {
        runZonedGuarded<Future<void>>(
                ()
            async
            {
                runApp(app);
            },
                (Object e, StackTrace stackTrace)
            {
                logError('##################################################');
                logError('# GoogleCrashlyticsService.run/runZoned/onError');
                logError(e.toString());
                logError(stackTrace.toString());
                logError('##################################################');

                if (_isEnabled)
                {
                    try
                    {
                        _crashlytics.recordError(e, stackTrace);
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
                        Map<String, dynamic> map =
                        {
                            'Exception': e.toString(),
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
}
