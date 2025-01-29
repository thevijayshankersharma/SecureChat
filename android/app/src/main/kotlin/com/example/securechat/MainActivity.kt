package com.example.securechat

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "com.example.securechat/sms"
    private val SMS_RECEIVED_CHANNEL = "com.example.securechat/sms_received"
    private lateinit var smsSender: SmsSender
    private var smsReceivedChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        smsSender = SmsSender(this)

        // Initialize the SMS sending channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phone = call.argument<String>("phone")
                    val message = call.argument<String>("message")

                    if (phone == null || message == null) {
                        result.error("INVALID_ARGUMENTS", "Phone number or message is null", null)
                        return@setMethodCallHandler
                    }

                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            smsSender.sendSMS(phone, message, result)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Error in sendSMS: ${e.message}")
                            result.error("UNEXPECTED_ERROR", e.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Initialize the SMS receiving channel
        smsReceivedChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_RECEIVED_CHANNEL)
    }

    // Method to be called from SmsReceiver when an SMS is received
    fun onSmsReceived(sender: String, message: String) {
        runOnUiThread {
            smsReceivedChannel?.invokeMethod(
                "onSmsReceived",
                mapOf(
                    "sender" to sender,
                    "message" to message
                )
            )
        }
    }

    override fun cleanUpFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        smsReceivedChannel = null
    }
}

