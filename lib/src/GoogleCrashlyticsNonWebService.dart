import 'dart:async';

import 'package:eggnstone_dart/eggnstone_dart.dart';
import 'package:eggnstone_flutter/eggnstone_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'IGoogleCrashlyticsService.dart';

typedef CrashReporterCallback = Function(Map<String, Object> params);

class GoogleCrashlyticsService
    implements IGoogleCrashlyticsService
{
    final FirebaseCrashlytics _firebaseCrashlytics;
    final CrashReporterCallback? _additionalCrashReporterCallback;
    final bool _isEnabled;

    bool _isDebugEnabled;

    GoogleCrashlyticsService._internal(this._firebaseCrashlytics, this._additionalCrashReporterCallback, bool isEnabled, bool isDebugEnabled)
        : _isEnabled = isEnabled, _isDebugEnabled = isDebugEnabled;

    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleCrashlyticsService> create(CrashReporterCallback? alternativeCrashReporterCallback, IAnalyticsService? analyticsService, bool startEnabled, bool startDebugEnabled)
    => GoogleCrashlyticsService.createMockable(FirebaseCrashlytics.instance, alternativeCrashReporterCallback, startEnabled, startDebugEnabled);

    // ignore: avoid_positional_boolean_parameters
    static Future<IGoogleCrashlyticsService> createMockable(FirebaseCrashlytics crashlytics, CrashReporterCallback? alternativeCrashReporterCallback, bool startEnabled, bool startDebugEnabled)
    async
    {
        final GoogleCrashlyticsService instance = GoogleCrashlyticsService._internal(crashlytics, alternativeCrashReporterCallback, startEnabled, startDebugEnabled);
        //instance._init();
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

    @override
    void onError(Object error, StackTrace stackTrace)
    {
        if (!_isEnabled)
        {
            logError('##################################################');
            logError('# Disabled-GoogleCrashlyticsService.onError');
            logError(error.toString());
            logError(stackTrace.toString());
            logError('##################################################');
            return;
        }

        try
        {
            unawaited(_firebaseCrashlytics.recordError(error, stackTrace));
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
            final Map<String, Object> map =
                <String, Object>
                {
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

    @override
    void setUserId(String value)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleCrashlytics' : 'Disabled-GoogleCrashlytics') + ': setUserId: $value');

        if (_isEnabled)
            unawaited(_firebaseCrashlytics.setUserIdentifier(value));
    }

    @override
    void setUserProperty(String key, String value)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleCrashlytics' : 'Disabled-GoogleCrashlytics') + ': setUserProperty: key=$key value=$value');

        if (_isEnabled)
            unawaited(_firebaseCrashlytics.setCustomKey(key, value));
    }

    @override
    void recordError(Object error, StackTrace stackTrace)
    {
        // ignore: prefer_interpolation_to_compose_strings
        logInfo((_isEnabled ? 'GoogleCrashlytics' : 'Disabled-GoogleCrashlytics') + ': recordError: error=$error stackTrace=$stackTrace');

        if (_isEnabled)
            unawaited(_firebaseCrashlytics.recordError(error, stackTrace));
    }
}
