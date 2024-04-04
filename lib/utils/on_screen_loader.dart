import 'package:flutter/material.dart';
import 'package:salarynow/utils/written_text.dart';

import 'color.dart';

class MyScreenLoader {
  static onScreenLoader(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}

class MyCallLoadingLoader {
  static onScreenCallLoading(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10.0),
                    DefaultTextStyle(
                      style: TextStyle(color: MyColor.turcoiseColor, fontWeight: FontWeight.bold, fontSize: 16),
                      child: Text(
                        MyWrittenText.verifyByCallWaiting,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  static onSelfieLoading(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10.0),
                    DefaultTextStyle(
                      style: TextStyle(color: MyColor.turcoiseColor, fontWeight: FontWeight.bold, fontSize: 16),
                      child: Text(
                        MyWrittenText.verifyByCallWaiting,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class MyCallSuccessfulStatus {
  static onScreenCallLoaded(BuildContext context) {
    print("CallLoaded SuccessFully");

    Dialog verifiedDailog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
        height: 200.0,
        width: 200.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, color: Colors.green, size: 80),
            SizedBox(
              height: 15,
            ),
            DefaultTextStyle(
                style: TextStyle(color: MyColor.turcoiseColor, fontWeight: FontWeight.bold, fontSize: 16),
                child: Text(
                  MyWrittenText.verifyByCallSuccessful,
                )),
          ],
        ),
      ),
    );

    showDialog(context: context, builder: (BuildContext context) => verifiedDailog);
  }

  /*
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => errorDialog
        /*
        {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(color: MyColor.turcoiseColor, fontWeight: FontWeight.bold, fontSize: 16),
                      child: Text(
                        MyWrittenText.verifyByCallWaiting,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }

         */
        );

     */
}
