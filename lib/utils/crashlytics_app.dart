import 'dart:developer';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salarynow/form_helper/form_helper_cubit/form_helper_cubit.dart';
import 'package:salarynow/storage/local_storage.dart';
import 'package:salarynow/storage/local_user_modal.dart';
import 'package:salarynow/utils/color.dart';
import '../registration/cubit/registration_cubit.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsApp {
  static final CrashlyticsApp _singleton = CrashlyticsApp._internal();

  factory CrashlyticsApp() {
    return _singleton;
  }

  CrashlyticsApp._internal();

  static FirebaseCrashlytics get instance => FirebaseCrashlytics.instance;

  void log(String message) {
    instance.log(message);
  }

  void setCustomKey(String key, dynamic value) {
    instance.setCustomKey(key, value);
  }

  void setUserIdentifier(String identifier) {
    instance.setUserIdentifier(identifier);
  }

  void recordError(dynamic error, StackTrace stack) {
    instance.recordError(error, stack);
  }

  // Additional methods
  void setCustomKeys(Map<String, dynamic> keys) {
    keys.forEach((key, value) {
      setCustomKey(key, value);
    });
  }
}
