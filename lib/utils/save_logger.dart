import 'package:shared_preferences/shared_preferences.dart';

class SaveLogger {
  static Future<void> log(String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> existingLogs = prefs.getStringList('logs') ?? [];
    String timestamp = DateTime.now().toString();
    String logEntry = '$timestamp: $message';
    existingLogs.add(logEntry);
    await prefs.setStringList('logs', existingLogs);
  }

  static Future<List<String>> getLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('logs') ?? [];
  }
}
