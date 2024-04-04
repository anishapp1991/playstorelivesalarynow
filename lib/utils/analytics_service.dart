import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService {

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);


  static Future<void> logAppOpen() async {
    await analytics.logAppOpen();
  }

  static Future<void> setCustUserID(String id) async {
    await analytics.setUserId(
      id: "SN::- $id",
    );
  }

  static Future<void> setCustUserProperty(String name,String value) async {
    await analytics.setUserProperty(
      name: "SN::- $name",
      value: "SN::- $value",
    );
  }

  static Future<void> setCustCurrentScreen(String screenName) async {
    await analytics.setCurrentScreen(
      screenName: "SN::- $screenName"
    );
  }

  static Future<void> logCustEvent(String name,Map<String, dynamic> parameters) async {
    await analytics.logEvent(
      name: "SN::- $name",
      parameters: parameters,
    );
  }




}
