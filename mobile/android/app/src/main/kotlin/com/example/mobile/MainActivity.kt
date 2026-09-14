package com.example.mobile

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.hulypay.app/google_pay"
    private val googlePayPackageName = "com.google.android.apps.nbu.paisa.user"
    private val googlePayRequestCode = 53001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "isReadyToPay" -> {
                    val isInstalled = checkGooglePayInstalled()
                    result.success(isInstalled)
                }
                "launchGooglePay" -> {
                    val upiUri = call.argument<String>("upiUri")
                    if (upiUri.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "upiUri is required", null)
                        return@setMethodCallHandler
                    }

                    val uri = Uri.parse(upiUri)
                    val gpayIntent = Intent(Intent.ACTION_VIEW, uri)
                    gpayIntent.setPackage(googlePayPackageName)

                    val intentToLaunch = if (gpayIntent.resolveActivity(packageManager) != null) {
                        gpayIntent
                    } else {
                        val genericUpiIntent = Intent(Intent.ACTION_VIEW, uri)
                        if (genericUpiIntent.resolveActivity(packageManager) != null) {
                            genericUpiIntent
                        } else {
                            null
                        }
                    }

                    if (intentToLaunch == null) {
                        result.error("NOT_INSTALLED", "Google Pay or a supported UPI app is not installed on this device", null)
                        return@setMethodCallHandler
                    }

                    pendingResult = result
                    try {
                        startActivityForResult(intentToLaunch, googlePayRequestCode)
                    } catch (e: Exception) {
                        pendingResult = null
                        result.error("LAUNCH_FAILED", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkGooglePayInstalled(): Boolean {
        return try {
            val testIntent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
            testIntent.setPackage(googlePayPackageName)
            val activities = packageManager.queryIntentActivities(testIntent, 0)
            activities.isNotEmpty()
        } catch (e: Exception) {
            false
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == googlePayRequestCode) {
            val resultMap = HashMap<String, Any?>()
            resultMap["resultCode"] = resultCode
            resultMap["isOk"] = (resultCode == Activity.RESULT_OK)
            resultMap["isCanceled"] = (resultCode == Activity.RESULT_CANCELED)

            if (data != null) {
                // 1. Capture full data URI string if returned via Intent data
                if (data.dataString != null) {
                    resultMap["dataString"] = data.dataString
                }
                if (data.data != null && data.data?.query != null) {
                    resultMap["query"] = data.data?.query
                }

                // 2. Iterate through all bundle extras dynamically
                data.extras?.let { bundle ->
                    for (key in bundle.keySet()) {
                        resultMap[key] = bundle.get(key)?.toString()
                    }
                }

                // 3. Ensure canonical keys are explicitly populated if present
                data.getStringExtra("tezResponse")?.let { resultMap["tezResponse"] = it }
                data.getStringExtra("response")?.let { resultMap["response"] = it }
                data.getStringExtra("Status")?.let { resultMap["Status"] = it }
                data.getStringExtra("status")?.let { resultMap["status"] = it }
                data.getStringExtra("txnId")?.let { resultMap["txnId"] = it }
                data.getStringExtra("responseCode")?.let { resultMap["responseCode"] = it }
                data.getStringExtra("ApprovalRefNo")?.let { resultMap["ApprovalRefNo"] = it }
                data.getStringExtra("txnRef")?.let { resultMap["txnRef"] = it }
            }

            pendingResult?.success(resultMap)
            pendingResult = null
        }
    }
}

