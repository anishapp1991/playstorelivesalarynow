
package com.app.salarynow

import android.R
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast

import com.exotel.verification.Timer;
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.exotel.verification.ConfigBuilder
import com.exotel.verification.ExotelVerification
import com.exotel.verification.TimerListener
import com.exotel.verification.VerificationListener
import com.exotel.verification.contracts.Config
import com.exotel.verification.contracts.VerificationFailed
import com.exotel.verification.contracts.VerificationStart
import com.exotel.verification.contracts.VerificationSuccess
import com.exotel.verification.exceptions.ConfigBuilderException
import com.exotel.verification.exceptions.PermissionNotGrantedException
import com.exotel.verification.exceptions.VerificationAlreadyInProgressException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {

    var eVerification: ExotelVerification? = null
    private val LOGGING_TAG = "VerificatrixDemoApp"
    private val accountSid = "salarynow"
    private val NotpAppId = "81579045d22d4678a3bfb7399c96d29c"
    private val appSecret = "lejafavujasu"


    private var activityResultCallback: ((String?) -> Unit)? = null




    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.app.salarynow/channel").setMethodCallHandler {
                call, rawResult ->
            var result: MethodChannel.Result = MethodResultWrapper(rawResult)
            if(call.method == "getFileFromPicker") {
                var methodCheckFlag: Boolean = true
                val isPdf: Boolean? = call.argument("isPdf")
                activityResultCallback = {
                    if(methodCheckFlag) {
                        methodCheckFlag = false;
                        result.success(it)
                    }
                }
                selectFile(isPdf)
            }else if(call.method == "initialize") {
                try {
                    initializeVerification()
                } catch (e: Exception) {
                    Log.e(LOGGING_TAG, "onCreate: Exception occured " + e.message)
                }

                val customTimer = Timer()
                customTimer.setTimerListener(TimerListener { time -> Log.v(LOGGING_TAG,"Please expect the verification call in " + (time / 1000).toString() + " seconds.") })

            } else if(call.method == "clickCallVerify") {
                var methodCheckFlag: Boolean = true
                val mobileNo: String? = call.argument("mobileNo")
                Log.v("clickCallVerify Mobile No.",""+mobileNo);
                try {
                    eVerification!!.startVerification(
                        object : VerificationListener {
                            override fun onVerificationStarted(verificationStart: VerificationStart) {
                                // You may choose to handle any started event here
                            }

                            override fun onVerificationSuccess(verificationSuccess: VerificationSuccess) {
                                if (methodCheckFlag) {
                                    methodCheckFlag = false
                                    // Send success result back to Flutter
                                    result.success(mapOf(
                                        "status" to "success",
                                        "msg" to ""
                                    ))
                                }
                            }

                            override fun onVerificationFailed(verificationFailed: VerificationFailed) {
                                result.success(mapOf(
                                    "status" to "error",
                                    "msg" to "${verificationFailed.getErrorMessage()}"
                                ))

                                Log.v(
                                    "Verify Listner Log",
                                    "Verification Failed:::: ${verificationFailed.getErrorMessage()}" + verificationFailed.requestID + " " + verificationFailed.errorCode + " " + verificationFailed.errorMessage + " " + verificationFailed.miscData
                                )
//                                result.success("failed")
                            }
                        },
                        "+91$mobileNo",
                        10
                    )


                } catch (e: VerificationAlreadyInProgressException) {
                    Log.e(LOGGING_TAG, "Exception: " + e.message)
                }
            }
            else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        activityResultCallback?.invoke(null)
        activityResultCallback = null

        super.onDestroy()
    }

    fun selectFile(isPdf: Boolean?) {
        val intent = Intent()
        if (isPdf == true) {
            intent.type = "application/pdf"
        } else {
            intent.type = "*/*"
        }
        intent.action = Intent.ACTION_OPEN_DOCUMENT
        startActivityForResult(intent, 100)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent? ) {
        if (resultCode != RESULT_OK) {
            activityResultCallback?.invoke(null)
            return super.onActivityResult(requestCode, resultCode, data)
        }
        if (requestCode == 100 && data != null && data.data != null) {
            val selectedImageUri = data.dataString
            activityResultCallback?.invoke(selectedImageUri)
        } else {
            activityResultCallback?.invoke(null)
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private class MethodResultWrapper constructor(result: MethodChannel.Result) : MethodChannel.Result {
        private val methodResult: MethodChannel.Result
        private val handler: Handler

        init {
            methodResult = result
            handler = Handler(Looper.getMainLooper())
        }


        override fun success(p0: Any?) {
            handler.post(
                object : Runnable {
                    override fun run() {
                        methodResult.success(p0)
                    }
                })
        }

        override fun error(p0: String, p1: String?, p2: Any?) {
            handler.post(
                object : Runnable {
                    override fun run() {
                        methodResult.error(p0, p1, p2)
                    }
                })
        }

        override fun notImplemented() {
            handler.post(
                object : Runnable {
                    override fun run() {
                        methodResult.notImplemented()
                    }
                })
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

         }



    private fun initializeVerification() {
        try {
            val config: Config =
                ConfigBuilder(NotpAppId, appSecret, accountSid, applicationContext).Build()
            eVerification = ExotelVerification(config)
        } catch (vPNGE: PermissionNotGrantedException) {
            Log.d(
                LOGGING_TAG,
                "initializeVerification: permission not granted exception: " + vPNGE.permission
            )
            askForPermission(vPNGE.permission, 1)

            //Try initializing again after 3 seconds
            Handler().postDelayed({ initializeVerification() }, 3000)
        } catch (cBE: ConfigBuilderException) {
            Log.d(LOGGING_TAG, "initializeVerification: ClientBuilder Exception!")
        }
    }

    private fun askForPermission(permission: String, requestCode: Int) {
        //if the user denied it perviously
        if (ContextCompat.checkSelfPermission(
                this@MainActivity,
                permission
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(
                    this@MainActivity,
                    permission
                )
            ) {
                //just asking them again for now
                ActivityCompat.requestPermissions(
                    this@MainActivity,
                    arrayOf(permission),
                    requestCode
                )
            } else {
                ActivityCompat.requestPermissions(
                    this@MainActivity,
                    arrayOf(permission),
                    requestCode
                )
            }
        } else {
            //permission already given
        }
    }

}
