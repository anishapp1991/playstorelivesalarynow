import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salarynow/splash_screen/cubit/splash_cubit.dart';
import 'package:salarynow/storage/local_storage.dart';
import 'package:salarynow/utils/save_logger.dart';
import 'package:salarynow/utils/snackbar.dart';

class DynamicLinkClass {
  Future<String> createLink(String path) async {
    final String url = "https://salarynow.in?$path";

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      link: Uri.parse(url),
      uriPrefix: "https://salarynowapp.page.link",
      androidParameters: const AndroidParameters(packageName: "com.app.salarynow", minimumVersion: 1),
      // iosParameters: const IOSParameters(bundleId: "com.example.app.ios"),
    );
    final FirebaseDynamicLinks dynamicLink = FirebaseDynamicLinks.instance;
    final refLink = await dynamicLink.buildShortLink(parameters);
    print("Created Link - ${refLink.shortUrl}");
    return refLink.shortUrl.toString();
  }

  void initDynamicLink() async {
    final instanceLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (instanceLink != null) {
      final Uri refLink = instanceLink.link;
      print("reflink ::: $refLink");
      // Fluttertoast.showToast(msg: refLink.toString());
    } else {
      print("No Link Found");
    }
  }

  Future<void> initDynamicLinks(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri uri = dynamicLinkData.link;
      final queryParams = uri.queryParameters;
      final utmParams = dynamicLinkData.utmParameters;
      print("Deep Links, UTM Params::: $utmParams, Query Params::: $queryParams");
      if (utmParams != null && utmParams.isNotEmpty) {
        print("UTM utm_campaign ::: ${utmParams["utm_campaign"]}, utm_medium ::: ${utmParams["utm_medium"]},utm_source ::: ${utmParams["utm_source"]}");
        SaveLogger.log("Deep Links, UTM Params::: $utmParams, Query Params::: $queryParams");
        MyStorage.setUTMTransactionData("${utmParams["utm_medium"]}");
        // BlocProvider.of<SplashCubit>(context).icubeInstallAndRegisterApp(transaction_id:"${utmParams["utm_medium"]}", goal_id: '7749',goal_name: 'register');
        // mCtx.read<SplashCubit>().icubeInstallAndRegisterApp(goal_id: '7749',goal_name: 'register');
      }
    }).onError((error) {
      print(error.message);
    });
  }
}

