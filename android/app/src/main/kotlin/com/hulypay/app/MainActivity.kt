package com.hulypay.app

import android.Manifest
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.ClipData
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

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
                    "isPackageInstalled" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName.isNullOrBlank()) {
                            result.error("INVALID_ARGS", "packageName is required", null)
                        } else {
                            val isInstalled = checkPackageInstalled(packageName)
                            result.success(isInstalled)
                        }
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
                    "launchAppPackage" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName.isNullOrBlank()) {
                            result.error("INVALID_ARGS", "packageName is required", null)
                        } else {
                            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                            if (launchIntent != null) {
                                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                try {
                                    startActivity(launchIntent)
                                    result.success(true)
                                } catch (e: Exception) {
                                    result.error("LAUNCH_FAILED", e.localizedMessage, null)
                                }
                            } else {
                                result.error("NOT_INSTALLED", "$packageName is not installed on this device", null)
                            }
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
                    "getInstalledUpiApps" -> {
                        val installedApps = getInstalledUpiPackages()
                        result.success(installedApps)
                    }
                    "launchUpiIntent" -> {
                        val upiUri = call.argument<String>("upiUri")
                        val packageName = call.argument<String>("packageName")
                        if (upiUri.isNullOrBlank()) {
                            result.error("INVALID_ARGS", "upiUri is required", null)
                            return@setMethodCallHandler
                        }

                        val uri = Uri.parse(upiUri)
                        val intent = Intent(Intent.ACTION_VIEW, uri)
                        if (!packageName.isNullOrBlank()) {
                            intent.setPackage(packageName)
                        }

                        // Check if an activity can resolve this intent
                        val canResolve = intent.resolveActivity(packageManager) != null
                        val intentToLaunch = if (canResolve) {
                            intent
                        } else if (!packageName.isNullOrBlank()) {
                            // Fallback to generic chooser if specific package cannot resolve
                            val genericIntent = Intent(Intent.ACTION_VIEW, uri)
                            if (genericIntent.resolveActivity(packageManager) != null) {
                                Intent.createChooser(genericIntent, "Pay with UPI")
                            } else {
                                null
                            }
                        } else {
                            // Generic chooser
                            Intent.createChooser(intent, "Pay with UPI")
                        }

                        if (intentToLaunch == null) {
                            result.error("NOT_INSTALLED", "No UPI application found to handle payment", null)
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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.hulypay/share_image").setMethodCallHandler { call, result ->
            when (call.method) {
                "shareImage" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val title = call.argument<String>("title") ?: "Share QR image"
                    val text = call.argument<String>("text")
                    val targetPackage = call.argument<String>("targetPackage")
                    if (imagePath.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "imagePath is required", null)
                        return@setMethodCallHandler
                    }
                    shareImage(imagePath, title, text, targetPackage, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun shareImage(imagePath: String, title: String, text: String?, targetPackage: String?, result: MethodChannel.Result) {
        try {
            android.util.Log.d("HulyPay", "[HulyPay] Preparing image for sharing: $imagePath, targetPackage: $targetPackage")
            val imageUri = resolveShareableUri(imagePath)
            if (imageUri == null) {
                android.util.Log.e("HulyPay", "[HulyPay] Failed to resolve shareable URI for: $imagePath")
                result.error("URI_RESOLUTION_FAILED", "Could not resolve shareable URI for image", null)
                return
            }

            val sendIntent = Intent(Intent.ACTION_SEND).apply {
                type = "image/*"
                putExtra(Intent.EXTRA_STREAM, imageUri)
                if (!text.isNullOrBlank()) {
                    putExtra(Intent.EXTRA_TEXT, text)
                }
                clipData = ClipData.newRawUri("QR Image", imageUri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            // If a specific target package (such as Google Pay) is requested and installed, launch directly into it
            val resolvedTargetPackage = if (!targetPackage.isNullOrBlank() && checkPackageInstalled(targetPackage)) {
                targetPackage
            } else if (targetPackage == null && checkPackageInstalled(googlePayPackageName)) {
                // If targetPackage is omitted but Google Pay is installed, check if preferred
                null
            } else {
                null
            }

            if (resolvedTargetPackage != null) {
                android.util.Log.d("HulyPay", "[HulyPay] Launching direct image share to package: $resolvedTargetPackage")
                sendIntent.setPackage(resolvedTargetPackage)
                sendIntent.addCategory(Intent.CATEGORY_DEFAULT)
                sendIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                grantUriPermission(resolvedTargetPackage, imageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                startActivity(sendIntent)
                android.util.Log.d("HulyPay", "[HulyPay] Direct share intent launched to $resolvedTargetPackage")
                result.success(true)
                return
            }

            // Fallback: Open system chooser sheet if target app is not installed or not specified
            android.util.Log.d("HulyPay", "[HulyPay] Opening Android Sharesheet with URI: $imageUri")
            val chooser = Intent.createChooser(sendIntent, title).apply {
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            val resInfoList = packageManager.queryIntentActivities(sendIntent, PackageManager.MATCH_DEFAULT_ONLY)
            for (resolveInfo in resInfoList) {
                val packageName = resolveInfo.activityInfo?.packageName
                if (packageName != null) {
                    try {
                        grantUriPermission(packageName, imageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    } catch (_: Exception) {}
                }
            }

            if (sendIntent.resolveActivity(packageManager) == null && resInfoList.isEmpty()) {
                android.util.Log.w("HulyPay", "[HulyPay] No apps found to handle image share intent")
                result.error("NO_APPS", "No compatible application found to share the QR image", null)
                return
            }

            startActivity(chooser)
            android.util.Log.d("HulyPay", "[HulyPay] Share intent launched")
            result.success(true)
        } catch (e: Exception) {
            android.util.Log.e("HulyPay", "[HulyPay] Error launching share intent", e)
            result.error("LAUNCH_FAILED", e.localizedMessage, null)
        }
    }

    private fun resolveShareableUri(imagePath: String): Uri? {
        if (imagePath.startsWith("content://")) {
            return Uri.parse(imagePath)
        }

        val cleanPath = if (imagePath.startsWith("file://")) {
            Uri.parse(imagePath).path ?: imagePath.substring(7)
        } else {
            imagePath
        }

        val file = File(cleanPath)
        if (!file.exists()) {
            return null
        }

        return try {
            val authority = "${applicationContext.packageName}.fileprovider"
            FileProvider.getUriForFile(this, authority, file)
        } catch (e: Exception) {
            // Fallback: If FileProvider cannot resolve the external path, copy to app cache and retry
            try {
                val cacheFile = File(cacheDir, "shared_qr_${System.currentTimeMillis()}.${file.extension.ifEmpty { "png" }}")
                file.copyTo(cacheFile, overwrite = true)
                val authority = "${applicationContext.packageName}.fileprovider"
                FileProvider.getUriForFile(this, authority, cacheFile)
            } catch (inner: Exception) {
                inner.printStackTrace()
                null
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
        return checkPackageInstalled(googlePayPackageName)
    }

    private fun checkPackageInstalled(pkg: String): Boolean {
        return try {
            val launchIntent = packageManager.getLaunchIntentForPackage(pkg)
            if (launchIntent != null) return true

            val testIntent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
            testIntent.setPackage(pkg)
            val activities = packageManager.queryIntentActivities(testIntent, 0)
            activities.isNotEmpty()
        } catch (e: Exception) {
            false
        }
    }

    private fun getInstalledUpiPackages(): List<String> {
        return try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
            val activities = packageManager.queryIntentActivities(intent, 0)
            activities.mapNotNull { it.activityInfo?.packageName }.distinct()
        } catch (e: Exception) {
            emptyList()
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
