import 'dart:async';

import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:eggnstone_google_crashlytics/google/IGoogleCrashlyticsService.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

typedef CrashReporterCallback = Function(Map<String, dynamic> params);

/// Requires [LoggerService]
class GoogleCrashlyticsService
    with LoggerMixin
    implements IGoogleCrashlyticsService
{
    final FirebaseCrashlytics _crashlytics;
    final CrashReporterCallback? _additionalCrashReporterCallback;

    bool _isEnabled;

    GoogleCrashlyticsService._internal(this._crashlytics, this._additionalCrashReporterCallback, this._isEnabled);

    /// Requires [LoggerService]
    static Future<IGoogleCrashlyticsService> create(CrashReporterCallback alternativeCrashReporter, bool startEnabled)
    => GoogleCrashlyticsService.createMockable(FirebaseCrashlytics.instance, alternativeCrashReporter, startEnabled);

    /// Requires [LoggerService]
    static Future<IGoogleCrashlyticsService> createMockable(FirebaseCrashlytics crashlytics, CrashReporterCallback alternativeCrashReporter, bool startEnabled)
    async
    {
        var instance = GoogleCrashlyticsService._internal(crashlytics, alternativeCrashReporter, startEnabled);
        instance._init();
        return instance;
    }

    void _init()
    {
        FlutterError.onError = (FlutterErrorDetails details)
        {
            logger.logError('##################################################');
            logger.logError('# GoogleCrashlyticsService/FlutterError.onError ');

            if (logger.isEnabled)
            {
                // TODO: move to LoggerService
                FlutterError.dumpErrorToConsole(details);
            }

            if (details.stack == null)
                logger.logError('No stacktrace available.');
            else
                logger.logError(details.stack.toString());

            logger.logError('##################################################');

            if (_isEnabled)
            {
                try
                {
                    _crashlytics.recordFlutterError(details);
                }
                catch (e2, stackTrace2)
                {
                    logger.logError('##################################################');
                    logger.logError('# GoogleCrashlyticsService/FlutterError.onError/_crashlytics.recordFlutterError');
                    logger.logError(e2.toString());
                    logger.logError(stackTrace2.toString());
                    logger.logError('##################################################');
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
                        logger.logError('##################################################');
                        logger.logError('# GoogleCrashlyticsService/FlutterError.onError/_additionalCrashReporterCallback');
                        logger.logError(e2.toString());
                        logger.logError(stackTrace2.toString());
                        logger.logError('##################################################');
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
                (e, stackTrace)
            {
                logger.logError('##################################################');
                logger.logError('# GoogleCrashlyticsService.run/runZoned/onError');
                logger.logError(e.toString());
                logger.logError(stackTrace.toString());
                logger.logError('##################################################');

                if (_isEnabled)
                {
                    try
                    {
                        _crashlytics.recordError(e, stackTrace);
                    }
                    catch (e2, stackTrace2)
                    {
                        logger.logError('##################################################');
                        logger.logError('# GoogleCrashlyticsService.run/runZoned/onError/_crashlytics.recordError');
                        logger.logError(e2.toString());
                        logger.logError(stackTrace2.toString());
                        logger.logError('##################################################');
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
                            logger.logError('##################################################');
                            logger.logError('# GoogleCrashlyticsService.run/runZoned/onError/_additionalCrashReporterCallback');
                            logger.logError(e2.toString());
                            logger.logError(stackTrace2.toString());
                            logger.logError('##################################################');
                        }
                    }
                }
            });
    }
}
