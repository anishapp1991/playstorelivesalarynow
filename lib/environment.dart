import 'package:package_info_plus/package_info_plus.dart';

const apiBaseUrlProd = "https://green.salarynow.in/salaryadmin/api_v3/";
const apiBaseUrlDev = "https://green.salarynow.in/salaryadmin/api_v3/";

enum EnvironmentType {
  dev(apiBaseUrlDev),
  prod(apiBaseUrlProd);

  const EnvironmentType(this.apiBaseUrl);
  final String apiBaseUrl;
}

class Environment {
  static EnvironmentType? _current;

  static Future<EnvironmentType> current() async {
    if (_current != null) {
      return _current!;
    }

    final packageInfo = await PackageInfo.fromPlatform();

    switch (packageInfo.packageName) {
      case "com.app.salarynow.dev":
        _current = EnvironmentType.dev;
        break;
      default:
        _current = EnvironmentType.prod;
    }
    return _current!;
  }
}
