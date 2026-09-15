package com.example.mobile

import android.Manifest
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.hulypay.app/google_pay"
    private val googlePayPackageName = "com.google.android.apps.nbu.paisa.user"
    private val googlePayRequestCode = 53001
    private val smsPermissionRequestCode = 53002

    private var methodChannel: MethodChannel? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var smsReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "isReadyToPay" -> {
                        val isInstalled = checkGooglePayInstalled()
                        result.success(isInstalled)
                    }
                    "launchStandaloneGooglePay" -> {
                        val launchIntent = packageManager.getLaunchIntentForPackage(googlePayPackageName)
                        if (launchIntent != null) {
                            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            try {
                                startActivity(launchIntent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("LAUNCH_FAILED", e.localizedMessage, null)
                            }
                        } else {
                            result.error("NOT_INSTALLED", "Google Pay is not installed on this device", null)
                        }
                    }
                    "isSmsPermissionGranted" -> {
                        val receiveGranted = ContextCompat.checkSelfPermission(this@MainActivity, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
                        val readGranted = ContextCompat.checkSelfPermission(this@MainActivity, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
                        result.success(receiveGranted && readGranted)
                    }
                    "requestSmsPermission" -> {
                        val receiveGranted = ContextCompat.checkSelfPermission(this@MainActivity, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
                        val readGranted = ContextCompat.checkSelfPermission(this@MainActivity, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
                        if (receiveGranted && readGranted) {
                            result.success(true)
                        } else {
                            pendingPermissionResult = result
                            ActivityCompat.requestPermissions(
                                this@MainActivity,
                                arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS),
                                smsPermissionRequestCode
                            )
                        }
                    }
                    "startSmsListener" -> {
                        startListeningForSms()
                        result.success(true)
                    }
                    "stopSmsListener" -> {
                        stopListeningForSms()
                        result.success(true)
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
    }

    private fun startListeningForSms() {
        if (smsReceiver != null) return

        smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
                    try {
                        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                        if (messages != null && messages.isNotEmpty()) {
                            val sender = messages[0].displayOriginatingAddress ?: ""
                            val timestamp = messages[0].timestampMillis
                            val bodyBuilder = StringBuilder()
                            for (msg in messages) {
                                bodyBuilder.append(msg.displayMessageBody)
                            }
                            val smsMap = HashMap<String, Any>()
                            smsMap["sender"] = sender
                            smsMap["body"] = bodyBuilder.toString()
                            smsMap["timestamp"] = timestamp

                            methodChannel?.invokeMethod("onSmsReceived", smsMap)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
        }

        val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION).apply {
            priority = 999
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.registerReceiver(this, smsReceiver!!, filter, ContextCompat.RECEIVER_EXPORTED)
        } else {
            registerReceiver(smsReceiver, filter)
        }
    }

    private fun stopListeningForSms() {
        if (smsReceiver != null) {
            try {
                unregisterReceiver(smsReceiver)
            } catch (e: Exception) {
                // Ignore if not registered
            }
            smsReceiver = null
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == smsPermissionRequestCode) {
            val isAllGranted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            pendingPermissionResult?.success(isAllGranted)
            pendingPermissionResult = null
        }
    }

    override fun onDestroy() {
        stopListeningForSms()
        super.onDestroy()
    }

    private fun checkGooglePayInstalled(): Boolean {
        return try {
            val launchIntent = packageManager.getLaunchIntentForPackage(googlePayPackageName)
            if (launchIntent != null) return true

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
                if (data.dataString != null) {
                    resultMap["dataString"] = data.dataString
                }
                if (data.data != null && data.data?.query != null) {
                    resultMap["query"] = data.data?.query
                }

                data.extras?.let { bundle ->
                    for (key in bundle.keySet()) {
                        resultMap[key] = bundle.get(key)?.toString()
                    }
                }

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
